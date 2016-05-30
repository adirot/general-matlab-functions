function [datax, datay, fileNames]  = getDataMan(varargin)
        %% An iterface to mark multiple points on multiple images.
        
        % When the image shows, use the mouse:
        % left click to select point, right click to delete, 
        % enter to move on to next image. 
        
        % Input (optional):
        % 'fileNames' - A cell array of strings (1 by length) with names of
        %               the image files.
        
        % 'fileNameJoker' - Use joker characters to specify file names of
        %                   images. for expamle to choose all jpg files:
        %                   '*.jpg'
        
        % 'oldx','oldy' - If you have old data points that you wont to
        %                 show on screen and add to the data you collate,
        %                 use oldx and oldy. each one is a cell array (1 by
        %                 num of images). oldx{1,i} should contain a vector
        %                 of the x coordinates for the i'th image.
        
        % 'helpLines' - If this is true, lines will be marked on image to
        %               seperate it to 9 different segments. Default is false 
        
        % 'delRad' - When you use right click to delete a point, every
        %            selection is deleted within a radius of 'delRad'.
        %            defalt is 5.
        
        % ** If both 'fileNames' and 'fileNameJoker' are not specified, all
        %    files in the current folder will be used **
        
        % Output:
        % 'datax', 'datay' - two cell arrays: datax{1,i} are the points
        %                    selected in image number i.
        
        % 'fileNames' - a cell array with all the names of the image files.
        
        
        % Usage examples:
        % Mark points on all jpg files in folder
        % [datax, datay, fileNames]  = getDataMan('fileNameJoker','*.jpg')
        
        % Mark points on all files in a spesified folder
        % [datax, datay, fileNames]  =...
        %           getDataMan('fileNameJoker','folderName\*')
        
        
        % A window will open, and the first image will show. you mark data
        % with a left mouse click and delete data with right mouse click.
        % to move on to the next image press enter.
        
        
        % get input parameters
        p = inputParser();
        addOptional(p, 'fileNames', []);
        addOptional(p, 'fileNameJoker', '*');
        addOptional(p, 'oldx', []);
        addOptional(p, 'oldy', []);
        addOptional(p, 'helpLines', false);
        addOptional(p, 'delRad', 5);
        parse(p, varargin{:});
        Results = p.Results;
        fileNames = Results.fileNames;
        fileNameJoker = Results.fileNameJoker;
        oldx = Results.oldx;
        oldy = Results.oldy;
        helpLines = Results.helpLines;
        delRad = Results.delRad;
        
        % find fileNames if necessary
        if isempty( fileNames )
            fileNames = dir( fileNameJoker );
            fileNames = {fileNames.name};
        end
        
        
        % chack validity of input argumants
        if ~iscell( fileNames )
            error( 'fileNames must be a cell array of strings' );
        end
        
        if ~iscell( oldx )
            error( 'oldx must be a cell array vectors' );
        end
        
        if ~iscell( oldy )
            error( 'oldy must be a cell array vectors' );
        end
        
        % start GUI for marking data on images
        for i = 1:length(fileNames)
            fileName = fileNames{1,i};
            im = imread(fileName);
            imshow(im);

            set(gcf,'units','normalized','outerposition',[0 0 1 1]);
            hold on;

            if ~isempty(oldx)
                plot(oldx{1,i},oldy{1,i},'+','color','b');
            end

            %% plot help lines
            if helpLines
                [ymax, xmax, ~] = size(im);
                plot([0 xmax], [ymax/3 ymax/3], 'b');
                plot([0 xmax], [2*ymax/3 2*ymax/3], 'b');
                plot([xmax/3 xmax/3], [0 ymax], 'b');
                plot([2*xmax/3 2*xmax/3], [0 ymax], 'b');
            end

            title(fileName);
            [x, y, button] =...
                my_ginputc('ShowPoints',true,'ConnectPoints',false);
            collectedx = x(button == 1);
            collectedy = y(button == 1);
            toDelx = x(button == 3);
            toDely = y(button == 3);
            
            % add old data
            if ~isempty( oldx )
                collectedx = [collectedx oldx{1,i}];
                collectedy = [collectedy oldy{1,i}];
            end
            
            [datax{1,i}, datay{1,i}] =...
                delRightClicks(collectedx, collectedy, toDelx, toDely, delRad);
            
            close all;
        end
        
        
        %% functions used in this code
        function [newCentersx, newCentersy]  =...
                delRightClicks (oldx , oldy, toDelx, toDely, delRad)
                
                % delete points "toDel" from the array "old"
                % point is deleted if it's distace from the old point is
                % 'delRad' pixels
            
                j = length(oldx);
                while ( j >= 1)
                    n = length(toDelx);
                    while ( n >= 1) 
                        if j>0
                                if ((dist2points([toDelx(n) toDely(n)]...
                                        ,[oldx(j) oldy(j)]) < delRad))
                                        toDelx(n) = [];
                                        toDely(n) = [];
                                        oldx(j) = [];
                                        oldy(j) = [];
                                        j = j - 1;
                                end
                        end
                        n = n - 1;
                    end
                    j = j - 1;
                end
                newCenters = struct;
                newCentersx = oldx;
                newCentersy = oldy;
        end
    
        function dist = dist2points(p1,p2)
        dist = sqrt((p1(:,1) - p2(:,1)).^2 + (p1(:,2) - p2(:,2)).^2);
end
end

