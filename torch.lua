local ffi  = require 'ffi'
local torchffi = require 'torchffi'

function register_torchwrappers(fftw)

   local function fftGeneric(inp, n, direction)
      local input
      if inp:dim() == 1 then -- assume that phase is 0
	 input = torch.DoubleTensor(inp:size(1), 2):fill(0)
	 input[{{}, 1}] = inp
      elseif inp:dim() == 2 and inp:size(2) == 2 then
	 input = inp:double()
      else
	 error('Input has to be 1D Tensor (Real FFT with N points) or ' .. 
		  '2D Tensor (Complex FFT with N points means tensor of size Nx2)')
      end
      n = n or input:size(1)
      if input:size(1) < n then
	 local temp = torch.DoubleTensor(n, 2):fill(0)
	 temp[{{1, input:size(1)},{}}] = input
	 input = temp
      elseif input:size(1) > n then
	 input = input[{{1,n},{}}]
      end
      local input_data = torch.data(input) -- double*
      local input_data_cast = ffi.cast('fftw_complex*', input_data)

      local noutput = input:size(1);
      local output = torch.DoubleTensor(noutput, 2);
      local output_data = torch.data(output);
      local output_data_cast = ffi.cast('fftw_complex*', output_data)

      local flags = fftw.ESTIMATE
      local plan  = fftw.plan_dft_1d(input:size(1), input_data_cast, output_data_cast, direction, flags)
      fftw.execute(plan)
      fftw.destroy_plan(plan)
      if direction == fftw.BACKWARD then
	 output = output:div(input:size(1)) -- normalize
      end
      return output:typeAs(inp)
   end


   local function fft(input, n)
      return fftGeneric(input, n, fftw.FORWARD)
   end

   local function ifft(input, n)
      return fftGeneric(input, n, fftw.BACKWARD)
   end

   if pcall(function() require 'torch' end) then
      torch.fft = fft
      torch.ifft = ifft
   end

end
