USE eierwerf_racing
;

insert into RAT_RacingTrack
(
	USR_CreatedBy
	,COD_Game
	,RAT_Name
	,COD_Type
	,COD_Series

	,COD_Sharing
	,RAT_Designer
	,RAT_Reference
	
	,COD_CarTheme
	,VEC_CarId
	,COD_CarClass
	
	,RAT_ForzaRouteId
	,RAT_CustomRoute

	,RAT_Laps
	,COD_Season
	,COD_TimeOfDay
	,COD_Weather
	,COD_TimeProgression
	
	,RAT_DefaultLapTimeMin
	,RAT_DistanceKM
	,RAT_SharingCode
	,COD_Difficulty
	
	,RAT_Description
)
VALUES
(
	1,
	0,
	'RAT_Name CourseName',
	1,
	NULL,

	0,
	'RAT_Designer',
	'RAT_Reference',
	
	1,
	NULL,
	0,
	
	NULL,
	'RAT_CustomRoute',

	5,
	2,
	3,
	4,
	1,
	
	5,
	10,
   123456789,
	4,
	
	'RAT_Description (Long Text ok)'
)
;

INSERT INTO RAT_RacingTrack
(
	USR_CreatedBy,
	COD_Game,
	RAT_Name,
	COD_Type,
	COD_Series,
	COD_Sharing,
	COD_CarTheme,
	COD_CarClass,
	VEC_CarId,
	COD_Season,
	COD_TimeOfDay,
	COD_Weather,
	COD_TimeProgression,
	RAT_SharingCode,
	COD_Difficulty,
	RAT_Description
)
VALUES
(
	2, /* USR_CreatedBy */
	0, /* COD_Game */
	'Test BP 01', /* RAT_Name */
	1, /* COD_Type */
	0, /* COD_Series */
	0, /* COD_Sharing */
	0, /* COD_CarTheme */
	0, /* COD_CarClass */
	NULL, /* VEC_CarId */
	0, /* COD_Season */
	0, /* COD_TimeOfDay */
	0, /* COD_Weather */
	0, /* COD_TimeProgression */
	500000001, /* RAT_SharingCode */
	0, /* COD_Difficulty */
	'auto-generated for DB/* RAT_Description'
)
;

INSERT INTO RAT_RacingTrack
(
	USR_CreatedBy,
	COD_Game,
	RAT_Name,
	COD_Type,
	COD_Series,
	COD_Sharing,
	COD_CarTheme,
	COD_CarClass,
	VEC_CarId,
	COD_Season,
	COD_TimeOfDay,
	COD_Weather,
	COD_TimeProgression,
	RAT_SharingCode,
	COD_Difficulty,
	RAT_Description
)
VALUES
(
	2, /* USR_CreatedBy */
	0, /* COD_Game */
	'Test BP 02', /* RAT_Name */
	1, /* COD_Type */
	1, /* COD_Series */
	0, /* COD_Sharing */
	1, /* COD_CarTheme */
	0, /* COD_CarClass */
	NULL, /* VEC_CarId */
	0, /* COD_Season */
	0, /* COD_TimeOfDay */
	0, /* COD_Weather */
	0, /* COD_TimeProgression */
	500000002, /* RAT_SharingCode */
	0, /* COD_Difficulty */
	'auto-generated for DB/* RAT_Description'
)
;

INSERT INTO RAT_RacingTrack
(
	USR_CreatedBy,
	COD_Game,
	RAT_Name,
	COD_Type,
	COD_Series,
	COD_Sharing,
	COD_CarTheme,
	COD_CarClass,
	VEC_CarId,
	COD_Season,
	COD_TimeOfDay,
	COD_Weather,
	COD_TimeProgression,
	RAT_SharingCode,
	COD_Difficulty,
	RAT_Description
)
VALUES
(
	2, /* USR_CreatedBy */
	0, /* COD_Game */
	'Test BP 03', /* RAT_Name */
	1, /* COD_Type */
	1, /* COD_Series */
	0, /* COD_Sharing */
	0, /* COD_CarTheme */
	0, /* COD_CarClass */
	20, /* VEC_CarId */
	0, /* COD_Season */
	0, /* COD_TimeOfDay */
	0, /* COD_Weather */
	0, /* COD_TimeProgression */
	500000003, /* RAT_SharingCode */
	0, /* COD_Difficulty */
	'auto-generated for DB/* RAT_Description'
)
;

INSERT INTO RAT_RacingTrack
(
	USR_CreatedBy,
	COD_Game,
	RAT_Name,
	COD_Type,
	COD_Series,
	COD_Sharing,
	COD_CarTheme,
	COD_CarClass,
	VEC_CarId,
	COD_Season,
	COD_TimeOfDay,
	COD_Weather,
	COD_TimeProgression,
	RAT_SharingCode,
	COD_Difficulty,
	RAT_Description
)
VALUES
(
	2, /* USR_CreatedBy */
	0, /* COD_Game */
	'Test BP 04', /* RAT_Name */
	1, /* COD_Type */
	1, /* COD_Series */
	0, /* COD_Sharing */
	0, /* COD_CarTheme */
	1, /* COD_CarClass */
	null, /* VEC_CarId */
	0, /* COD_Season */
	0, /* COD_TimeOfDay */
	0, /* COD_Weather */
	0, /* COD_TimeProgression */
	500000004, /* RAT_SharingCode */
	0, /* COD_Difficulty */
	'auto-generated for DB/* RAT_Description'
)
;

INSERT INTO RAV_RatingVote (RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote) VALUES ('RAT', 87, 2, 1);
INSERT INTO RAV_RatingVote (RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote) VALUES ('RAT', 87, 3, 1);
INSERT INTO RAV_RatingVote (RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote) VALUES ('RAT', 87, 4, 1);
INSERT INTO RAV_RatingVote (RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote) VALUES ('RAT', 87, 5, 1);
INSERT INTO RAV_RatingVote (RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote) VALUES ('RAT', 87, 6, -1);


INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 01', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 02', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 03', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 04', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 05', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 06', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 07', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 08', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 09', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 10', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 11', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 12', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 13', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 14', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 15', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 16', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 17', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 18', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 19', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 20', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 21', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 23', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 24', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 25', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 26', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 27', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 28', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 29', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 30', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 31', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 32', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 33', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 34', 'just test data');
INSERT INTO CMP_Championship (USR_CreatedBy, COD_SharingMode, COD_Game, CMP_Name, CMP_Description) VALUES (2, 0, 0, 'Test CMP 35', 'just test data');

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 01, 1, 47, 3, 0, NULL, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 01, 2, 14, 1, 0, NULL, 6, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 01, 3, 8, 1, 7, NULL, 7, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 01, 4, 15, 1, 0, 83, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 02, 1, 47, 3, 0, NULL, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 02, 2, 14, 1, 0, NULL, 6, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 02, 3, 8, 1, 7, NULL, 7, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 02, 4, 15, 1, 0, 83, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 03, 1, 47, 3, 0, NULL, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 03, 2, 14, 1, 0, NULL, 6, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 03, 3, 8, 1, 7, NULL, 7, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression)
VALUES
(2, 03, 4, 15, 1, 0, 83, 0, 0, 0, 1);

INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 04, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 05, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 06, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 07, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 08, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 09, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 10, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 11, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 12, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 13, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 14, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 15, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 16, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 17, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 18, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 19, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 20, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 21, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 22, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 23, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 24, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 25, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 26, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 27, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 28, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 29, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 30, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 31, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 32, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 33, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 34, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
INSERT INTO RCE_Race
(USR_CreatedBy, CMP_ChampionshipId, RCE_RaceNo, RAT_TrackId, COD_Series, COD_CarTheme, VEC_CarId, COD_CarClass, COD_TimeOfDay, COD_Weather, COD_TimeProgression) VALUES (2, 35, 1, 75, 4, 11, NULL, 0, 0, 0, 1);
