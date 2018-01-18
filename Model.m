classdef Model < handle
   properties(Static)
      alpha = 1/3
      consistency_threshold = 0.4
   end

   properties
      Rate
      Predicted

      Color
      MixedColor
      Radius
   end

   methods
      function this = Model(frame0, frame)
         this.Rate = 2;
         this.Predicted = 1;
         this.Color = (1-Model.alpha)*frame0.Color + Model.alpha*frame.Color;
         this.Radius = (1-Model.alpha)*frame0.Radius + Model.alpha*frame.Radius;
         this.MixedColor = frame.MixedColor;
      end

      function [] = update(this, frame)
         this.Rate = this.Rate + 1;
         this.Color = (1-Model.alpha)*this.Color + Model.alpha*frame.Color;
         this.Radius = (1-Model.alpha)*this.Radius + Model.alpha*frame.Radius;
         this.MixedColor = frame.MixedColor;
      end

      function loss = calc_loss(this, frame)
         [~,d] = knnMatch(frame,this,'color');
         loss = abs(this.Radius - frame.Radius) + 10*d;
      end
   end

end

