classdef (Abstract) Outline


methods (Static)


function annotations = orderedOutlines ( user )
	[ ~, img_order ] = sort( User.Data.Order.images( user.data.outline ) );
	nb_img = length( img_order );
	annotations = cell( 1, nb_img );
	for i = 1:nb_img
		% Should I use Outline.regularize here ?
		annotations{i} = user.data.outline{ img_order(i) }.annotations{1};
	end
end


function annotations = orderedRegularizedOutlines ( user, distance )
	if nargin < 2
		distance = 10;
	end
	annotations = Utils.mycellfun ...
		( @(outline) Outline.regularize( outline, distance ) ...
		, User.Eval.Outline.orderedOutlines( user ) ...
		);
end



function [ precisions, recalls, jaccards, masks ] = bg ( user, groundtruths )
	gts = Utils.mycellfun( @(gt) ~gt, groundtruths );
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	gt_sizes = Utils.mycellfun( @size, groundtruths );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( gts, @Outline.bgMask, outlines, gt_sizes );
end


function [ precisions, recalls, jaccards, masks ] = fg ( user, groundtruths )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	gt_sizes = Utils.mycellfun( @size, groundtruths );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.fgMask, outlines, gt_sizes );
end


function [ precisions, recalls, jaccards, masks ] = skeleton ( user, groundtruths )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	radius_thresholds = Utils.mycellfun ...
		( @(outline) 0.5*Outline.maxRadius( outline ), outlines );
	gt_sizes = Utils.mycellfun( @size, groundtruths );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.skeletonMask, outlines, radius_thresholds, gt_sizes );
end


function [ precisions, recalls, jaccards, masks ] = skeletonSP ( user, groundtruths, all_sp )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	radius_thresholds = Utils.mycellfun ...
		( @(outline) 0.5*Outline.maxRadius( outline ), outlines );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.skeletonSP, outlines, radius_thresholds, all_sp );
end


function [ precisions, recalls, jaccards, masks ] = erosion ( user, groundtruths )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	gs_id = 1;
	gs_radius = Outline.goldStandardRadius( outlines{ gs_id }, groundtruths{ gs_id } );
	radius_erosions = num2cell( repmat( round( gs_radius ), 1, length( outlines ) ) );
	gt_sizes = Utils.mycellfun( @size, groundtruths );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.fgEroded, outlines, radius_erosions, gt_sizes );
end


function [ precisions, recalls, jaccards, masks ] = erosionSP ( user, groundtruths, all_sp )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	gs_id = 1;
	gs_radius = Outline.goldStandardRadius( outlines{ gs_id }, groundtruths{ gs_id } );
	radius_erosions = num2cell( repmat( round( gs_radius ), 1, length( outlines ) ) );
	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.fgErodedSP, outlines, radius_erosions, all_sp );
end


function [ precisions, recalls, jaccards, masks ] = grabcut ( user, images, groundtruths, all_sp, method, constraint )
	outlines = User.Eval.Outline.orderedRegularizedOutlines( user );
	gs_id = 1;
	if strcmp(method,'erosion')
		gs_radius = Outline.goldStandardRadius( outlines{ gs_id }, groundtruths{ gs_id } );
		radius_thresholds = num2cell( repmat( round( gs_radius ), 1, length( outlines ) ) );
	elseif strcmp(method,'skeleton')
		radius_thresholds = Utils.mycellfun ...
			( @(outline) 0.5*Outline.maxRadius( outline ), outlines );
	elseif strcmp(method, 'none')
		radius_thresholds = cell( 1,length( outlines ) );
	end

	methods = repmat( { method }, 1, length( outlines ) );
	constraints = repmat( { constraint }, 1, length( outlines ) );

	[ precisions, recalls, jaccards, masks ] = User.Eval.method ...
		( groundtruths, @Outline.grabcut, images, outlines, radius_thresholds, all_sp, methods, constraints );
end


end % methods


end
