local ffi  = require 'ffi'
local fftw = require 'fftw3'
local torchffi = require 'torchffi'

local bit = require 'bit'


local function fft1d(input)
   assert(input:dim() == 1)
   local input_data = torch.data(input) -- double*

   local noutput = input:size(1)/2 + 1;
   local output = torch.DoubleTensor(noutput, 2);
   local output_data = torch.data(output);
   local output_data_cast = ffi.cast('fftw_complex*', output_data)

   local flags = fftw.ESTIMATE
   local plan  = fftw.plan_dft_r2c_1d(input:size(1), input_data, output_data_cast, flags)
   fftw.execute(plan)
   return output
end

local function ifft1d(input)
   assert(input:dim() == 2)
   local input_data = torch.data(input) -- double*
   local input_data_cast = ffi.cast('fftw_complex*', input_data)

   local noutput = (input:size(1) - 1) * 2;
   local output = torch.DoubleTensor(noutput):zero();
   local output_data = torch.data(output);

   local flags = fftw.ESTIMATE
   local plan  = fftw.plan_dft_c2r_1d(input:size(1), input_data_cast, output_data, flags)
   fftw.execute(plan)
   return output
end



input = torch.Tensor(8); -- torch.randn(1024):fill(1) -- double tensor
input[1] = 10
input[2] = 15
input[3] = 13
input[4] = 15
input[5] = 45
input[6] = 64
input[7] = 34
input[8] = 665

output = fft1d(input)
input2 = ifft1d(output)




-- require 'audio'
-- input2 = input:clone()
-- input2:resize(1,8)
-- output2 = audio.stft(input2, 8, 'rect', 1)