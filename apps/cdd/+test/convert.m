function convert( indir, outdir, ids, logfile )
% raw conversion statistics
%
% CONVERT( indir, outdir, ids, logfile )
%
% INPUT
% indir : input directory (row char)
% outdir : output directory (row char)
% ids : subject identifiers (row numeric)
% logfile : logger filename (row char)

		% safeguard
	if nargin < 1 || ~isrow( indir ) || ~ischar( indir ) || ... % input directory
			exist( indir, 'dir' ) ~= 7
		error( 'invalid argument: indir' );
	end

	if nargin < 2 || ~isrow( outdir ) || ~ischar( outdir ) % output directory
		error( 'invalid argument: outdir' );
	end

	if nargin < 3 || ~isrow( ids ) || ~isnumeric( ids ) % subject identifiers
		error( 'invalid arguments: ids' );
	end

	if nargin < 4 || ~isrow( logfile ) || ~ischar( logfile ) % logger filename
		error( 'invalid argument: logfile' );
	end

		% init
	if exist( outdir, 'dir' ) ~= 7 % prepare for output
		mkdir( outdir );
	end

	addpath( '../../cdf/' ); % include framework

	logger = xis.hLogger.instance( logfile ); % start logging
	logger.tab( 'raw conversion statistics...' );

		% workload
	sexes = cell( 1, max( ids ) );
	ages = NaN( 1, max( ids ) );

	cid = 1;
	for id = ids % proceed subjects
		logger.tab( 'subject: %d (%d/%d)...', id, cid, numel( ids ) );

			% read data
		cdffile = fullfile( indir, sprintf( 'run_%d.mat', id ) );
		logger.tab( 'read cdf data (''%s'')...', cdffile );

		load( cdffile, 'run' );

		logger.log( 'sex: %s', run.sex );
		logger.log( 'age: %d', run.age );
		logger.log( 'trials: %d', numel( run.trials ) );

		logger.untab();

			% gather statistics
		sexes{id} = run.sex;
		ages(id) = run.age;

			% clean up
		delete( run );

		cid = cid + 1;
		logger.untab();
	end

		% plot statistics
	[~, logname, ~] = fileparts( logfile );
	figfile = fullfile( outdir, sprintf( '%s.png', logname ) );
	logger.log( 'plot raw conversion statistics (''%s'')...', figfile );

	style = xis.hStyle.instance();
	fig = style.figure();

	xl = [floor( min( ages ) / 10 ) * 10, ceil( max( ages ) / 10 ) * 10]; % axis scaling

	hax = subplot( 3, 2, [1, 5] ); % sex

	title( sprintf( 'CONVERT (''%s'')', logname ) );
	xlabel( 'sex' );
	ylabel( 'subjects' );

	xlim( [0.5, 2.5] );

	set( hax, 'XTick', [1, 2] );
	set( hax, 'XTickLabel', {'female', 'male'} );

	females = 0;
	males = 0;
	for id = ids
		if strcmp( sexes{id}, 'w' )
			females = females + 1;
		else
			males = males + 1;
		end
	end

	bar( [1, 2], [females, males], ...
		'BarWidth', style.scale( -1 ), ...
		'EdgeColor', style.color( 'cold', -2 ), 'FaceColor', style.color( 'cold', -1 ) );

	subplot( 3, 2, 2 ); % age, female
	xlabel( 'age (female)' );
	ylabel( 'subjects' );

	xlim( xl );

	agex = 1:xl(2);
	agey = zeros( size( agex ) );
	for id = ids
		if strcmp( sexes{id}, 'w' ) % females only
			agey(ages(id)) = agey(ages(id)) + 1;
		end
	end

	bar( agex, agey, ...
		'BarWidth', style.scale( -1 ), ...
		'EdgeColor', style.color( 'cold', -2 ), 'FaceColor', style.color( 'cold', -1 ) );

	subplot( 3, 2, 4 ); % age, male
	xlabel( 'age (male)' );
	ylabel( 'subjects' );

	xlim( xl );

	agex = 1:xl(2);
	agey = zeros( size( agex ) );
	for id = ids
		if strcmp( sexes{id}, 'm' ) % males only
			agey(ages(id)) = agey(ages(id)) + 1;
		end
	end

	bar( agex, agey, ...
		'BarWidth', style.scale( -1 ), ...
		'EdgeColor', style.color( 'cold', -2 ), 'FaceColor', style.color( 'cold', -1 ) );

	subplot( 3, 2, 6 ); % age, total
	xlabel( 'age (total)' );
	ylabel( 'subjects' );

	xlim( xl );

	agex = 1:xl(2);
	agey = zeros( size( agex ) );
	for id = ids
		agey(ages(id)) = agey(ages(id)) + 1;
	end

	bar( agex, agey, ...
		'BarWidth', style.scale( -1 ), ...
		'EdgeColor', style.color( 'cold', -2 ), 'FaceColor', style.color( 'cold', -1 ) );

	style.print( figfile );
	delete( fig );

		% exit
	logger.untab(); % stop logging
	logger.log( 'done.' );

end

