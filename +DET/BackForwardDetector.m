classdef BackForwardDetector < DET.IDetector
	properties
		method = 'bicubic'
	end

	methods
		function this = BackForwardDetector(sz)
			Size = sz;
			Size_r = round(sz * this.scale_factor);
			this.do_post_process = false;
		end

		function [fmos, delta_bin] = detect(this,im,im0,im1)
			fmos = [];
			im_r = imresize(im, this.scale_factor, this.method);
			im0_r = imresize(im0, this.scale_factor, this.method);
			im1_r = imresize(im1, this.scale_factor, this.method);
			[delta_bin, delta_pm_bin, delta_p_bin, delta_m_bin] = this.get_deltas(im_r,im0_r,im1_r);
			delta_pm_bin = Differential.remove_noise(delta_pm_bin);
			
			regions_fmo = this.get_regions_fmo(delta_bin, delta_pm_bin);
			bin0 = delta_p_bin & ~delta_m_bin & ~delta_bin;
			bin1 = ~delta_p_bin & delta_m_bin & ~delta_bin;
			for i = 1:numel(regions_fmo)
				regions_fmo(i).Direction = Frame.check_ori(regions_fmo(i), bin0, bin1);
			end
			if isempty(regions_fmo)
				return
			end
			fmos = regions_fmo([regions_fmo.Direction] ~= 0);
			fmos = Frame.scale_back(fmos,this.scale_factor);
		end

		
	end
end
