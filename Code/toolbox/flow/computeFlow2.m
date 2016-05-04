% computeFlow2
%   Img1    - 1st input image.
%   Img2    - 2nd input image.
%   opt     - Structure with fields:
%             * nLevel: This is the maximum number of levels used in the 
%                       image pyramid. The actual number of levels used can 
%                       be smaller and depends on the input image. The 
%                       number of levels is at most 
%                           1 + ceil(log(16.0/min(nY, nX))/log(sFactor)), 
%                       where nY and nX denote the height and width of the 
%                       image, respectively.
%             * sFactor: Scaling factor between levels of subsequent images 
%                        in the image pyramid.
%             * nWarp: Number of warping steps.
%             * nIter: Number of iterations between the primal/dual problem.
%             * lambda: A parameter that controls the smoothness of the 
%                       solution.
% RETURN
%   Dx      - Horizontal flow component in units of pixels/frame.
%   Dy      - Vertical flow component in units of pixels/frame.
%
%
%   Florian Raudies, 01/17/2016, Palo Alto, CA.