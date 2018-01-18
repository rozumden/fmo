classdef Video < handle
   properties(Static)

   end

   properties
      file
      object
      result
      gt

      last_read
      k
   end

   methods
      function this = Video(folder, name)
         file = fullfile(folder,'seq',name);
         this.file = file;
         if exist(file) == 7 || exist(file) == 0 
            keyboard
            return
         end

         global check_file;
         if isempty(check_file)
            check_file = containers.Map;
         end
         if check_file.isKey(file)
            v = check_file(file);
            if ~isvalid(v)
               v = VideoReader(file);
               check_file(file) = v;
            end
         else
            was_caught = false;
            try
               v = VideoReader(file);
            catch 
               v = VideoReader(file);
            end
            check_file = [check_file; containers.Map(file, v)];
         end
         file_gt = fullfile(folder,'gt',name);
         this.gt = GroundTruth(file_gt,0);
         this.object = v;
         this.k = 1;
      end

      function [] = close(this)
         this.object.close();
      end

      function frame = get_next(this)
         frame = [];
         if this.has_next()
            frame = this.get_frame(this.k);
            this.k = this.k + 1;
         end
      end

      function has = has_next(this)
         has = this.k <= this.size();
      end

      function framed = get_frame(this, n)
         try
            this.last_read = this.object.read(n);
         catch
            warning('Cannot read frame.');
         end
         framed = im2double(this.last_read);
      end

      function [] = show_frame(this, n)
         imshow(this.object.read(n));
      end

      function num = size(this)
         num = this.object.NumberOfFrames;
      end
   end

end

