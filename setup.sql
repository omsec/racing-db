-- https://stackoverflow.com/questions/6134006/are-table-names-in-mysql-case-sensitive

-- Copyright Notes
-- according to https://forums.forzamotorsport.net/turn10_postsm976461_Event-race-List.aspx

-- be aware;
-- this file inserts a developer user "roger" into USR_User
-- which should be removed when deployed to production

-- ACHTUNG
-- auf dem Server ist MySql installiert, nicht MariaDB
-- Unterschiede:
-- 	* case-sensitive (Objektnamen UND Aliasnamen)
--	* keine Sub-Queries oder CTEs in Views unterstützt
--	* keine Window/OLTP-Funktionen
--  * auskommentiere SQLs mit Abstand -- SELECT
--  * keine Sonderzeichen/Umlaute im phpMyAdmin benutzen

USE eierwerf_racing
;

DROP TABLE if EXISTS COD_CodeLookup
;
DROP TABLE if exists TXT_TextTranslation
;
DROP TABLE if exists TAG_TagAssignment
;
DROP TABLE if EXISTS MVC_MultiValueCode
;
DROP TABLE if EXISTS MVF_MultiValueFile
;
DROP TABLE if EXISTS USR_User
;
DROP TABLE if EXISTS RAV_RatingVote
;
DROP TABLE if EXISTS RAT_RacingTrack
;
DROP TABLE if EXISTS VEC_Vehicle
;
DROP TABLE if EXISTS VTT_VehicleTypesThemes
;
DROP TABLE if EXISTS CMP_Championship
;
DROP TABLE if EXISTS RCE_Race
;
DROP TABLE if EXISTS CMT_Comment
;

DROP PROCEDURE if EXISTS listCodeTypes
;
DROP PROCEDURE if EXISTS createMvcEntry
;
DROP PROCEDURE if EXISTS listMvcEntries
;
DROP PROCEDURE if EXISTS deleteMvcEntries
;
DROP PROCEDURE if EXISTS createMvfEntry
;
DROP PROCEDURE if EXISTS listMvfEntries
;
DROP PROCEDURE if EXISTS deleteMvfEntry
;
DROP PROCEDURE if EXISTS deleteMvfEntries
;
DROP PROCEDURE if EXISTS readFileName
;
DROP PROCEDURE if EXISTS readVote
;
DROP PROCEDURE if EXISTS readRating
;
DROP PROCEDURE if EXISTS createUser
;
DROP PROCEDURE if EXISTS existsUser
;
DROP PROCEDURE if EXISTS readUser
;
DROP PROCEDURE if exists loginUser
;
DROP PROCEDURE if EXISTS listUsers
;
DROP PROCEDURE if EXISTS listContent
;
DROP PROCEDURE if EXISTS readTrack
;
DROP PROCEDURE if EXISTS searchCarNames
;
DROP PROCEDURE if EXISTS createTrack
;
DROP PROCEDURE if EXISTS createTag
;
DROP PROCEDURE if EXISTS updateTrack
;
DROP PROCEDURE if EXISTS createChampionship
;
DROP PROCEDURE if EXISTS createRace
;
DROP PROCEDURE if EXISTS searchTrackNames
;
DROP PROCEDURE if EXISTS searchTrackNamesBP
;
DROP PROCEDURE if EXISTS readChampionship
;
DROP PROCEDURE if EXISTS listRaces
;
DROP PROCEDURE if EXISTS updateVote
;
DROP PROCEDURE if EXISTS listTracks
;
DROP PROCEDURE if EXISTS int_searchChampionships
;
DROP PROCEDURE if EXISTS searchChampionships
;
DROP PROCEDURE if EXISTS readPassword
;
DROP PROCEDURE if EXISTS updatePassword
;
DROP PROCEDURE if EXISTS updateUser
;
DROP PROCEDURE if EXISTS countChampionships
;
DROP PROCEDURE if EXISTS listChampionships
;
DROP PROCEDURE if EXISTS searchTracks -- ToDo: Remove after PRD-DEployment
;
DROP PROCEDURE if EXISTS searchCustomTracks
;
DROP PROCEDURE if EXISTS searchCustomTrackNames
;
DROP PROCEDURE if EXISTS searchStandardTrackNames
;
DROP PROCEDURE if EXISTS deleteTrack
;
DROP PROCEDURE if EXISTS createComment
;
DROP PROCEDURE if EXISTS listComments
;
DROP PROCEDURE if EXISTS updateComment
;
DROP PROCEDURE if EXISTS deleteComment
;
DROP PROCEDURE if EXISTS readVoting
;
DROP PROCEDURE if EXISTS countUserVotes
;

DROP VIEW if EXISTS V_Votes
;
DROP VIEW if EXISTS V_Rating
;
DROP VIEW if EXISTS V_RacingTrack
;
DROP VIEW if EXISTS V_Car
;
DROP VIEW if EXISTS V_Search
;
DROP VIEW if EXISTS V_ChampionshipInfo1
;
DROP VIEW if EXISTS V_ChampionshipInfo2
;
DROP VIEW if EXISTS V_Championship
;
DROP VIEW if EXISTS V_User
;

CREATE TABLE COD_CodeLookup
(
	COD_RowId INT AUTO_INCREMENT PRIMARY KEY,
	COD_Domain VARCHAR(30) NOT NULL,
	COD_Value INT NOT NULL,
	COD_Language INT NOT NULL,
	COD_Text VARCHAR(50) NOT null
)
;
CREATE UNIQUE INDEX UI_CodeLookup1 ON COD_CodeLookup (COD_Domain, COD_Value, COD_Language)
;

-- used to translate content (such as event names)
CREATE TABLE TXT_TextTranslation
(
	TXT_RowId INT AUTO_INCREMENT PRIMARY KEY,
	TXT_TableRef CHAR(3) NOT NULL, -- RAT, VEC... (internal)
	TXT_ObjectId INT NOT NULL, -- FK to anything such as RAT_TrackId (rowid)
	COD_Language INT NOT NULL,
	TXT_Text VARCHAR(50)	
)
;
CREATE UNIQUE INDEX UI_TextTranslation1 ON TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language)
;

CREATE TABLE MVC_MultiValueCode (
	MVC_RowId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	MVC_TableRef CHAR(3) NOT NULL,
	MVC_RecordId INT NOT NULL,
	COD_Domain VARCHAR(20) NOT NULL,
	COD_Value INT NOT NULL
)
;
CREATE INDEX NI_MultiValueCode1 ON MVC_MultiValueCode (MVC_TableRef, MVC_RecordId, COD_Domain)
;
CREATE UNIQUE INDEX UI_MultiValueCode2 ON MVC_MultiValueCode (MVC_TableRef, MVC_RecordId, COD_Domain, COD_Value) -- allows sortings
;


CREATE TABLE MVF_MultiValueFile
(
	MVF_RowId INT AUTO_INCREMENT PRIMARY KEY,
	USR_CreatedBy INT NOT NULL,
	MVF_TableRef CHAR(3) NOT NULL, -- RAT, USR... (internal/api)
	MVF_RecordId INT NOT NULL, -- FK to anything such as RAT_TackId (rowid)
	MVF_Uploaded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- logical order of multiple files (e.g. galleries/carousel)
	MVF_FileName VARCHAR(50) NOT NULL, -- server's storage name
	MVF_Original VARCHAR(50) NOT NULL, -- displayed in client
	MVF_Description VARCHAR(20) NULL -- e.g. "dangerous left-turn"
)
;
CREATE INDEX NI_MultiValueFile1 ON MVF_MultiValueFile (MVF_TableRef, MVF_RecordId)
;
CREATE UNIQUE INDEX UI_MultiValueFile2 ON MVF_MultiValueFile (MVF_TableRef, MVF_RecordId, MVF_Uploaded) -- allows sortings
;

CREATE TABLE USR_User
(
	USR_UserId INT AUTO_INCREMENT PRIMARY KEY,
	USR_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL,
	USR_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT,
	USR_LoginName VARCHAR(50) NOT NULL,
	USR_LoginActive BOOLEAN NOT NULL DEFAULT FALSE,
	-- COD_LoginInactiveReason
	-- USR_LoginInactiveUntil
	USR_Password VARCHAR(255) NOT NULL,
	USR_XBoxTag VARCHAR(50),
	USR_DiscordName VARCHAR(50),
	COD_Role INT NOT NULL DEFAULT 0,
	COD_Language INT NOT NULL DEFAULT 0,
	USR_LastSeen TIMESTAMP NULL,
	COD_Rank INT NOT NULL DEFAULT 0
)
;
CREATE UNIQUE INDEX UI_User1 ON USR_User (USR_LoginName)
;

CREATE TABLE RAV_RatingVote (
	RAV_RowId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	RAV_TableRef CHAR(3) NOT NULL,
	RAV_RecordId INT NOT NULL,
	USR_UserId INT NOT NULL,
	RAV_Vote SMALLINT NOT NULL -- 1 = positive, -1 = negative
)
;
CREATE INDEX NI_RatingVote1 ON RAV_RatingVote (RAV_TableRef, RAV_RecordId)
;
CREATE INDEX NI_RatingVote2 ON RAV_RatingVote (USR_UserId)
;

CREATE TABLE RAT_RacingTrack -- event or blueprint
(
	-- meta data
	RAT_TrackId INT AUTO_INCREMENT PRIMARY KEY,
	RAT_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL, -- technischer ersteller; falls drittperson
	RAT_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT NULL,
	
	-- standards tracks ("routes") which come with games
	COD_Game INT NOT NULL,
	RAT_Name VARCHAR(50) NOT NULL, -- custom events or default (EN) for standards (TXT for translations)
	COD_Type INT NOT NULL, -- standard/custom course
	COD_Series INT NULL, -- optional for community routes
	
	-- information related to community routes (events/blueprints)
	COD_Sharing INT NULL, -- sharing option for custom tracks (all, roles)	
	RAT_Designer VARCHAR(50) NULL, -- effective designer of custom track, credits
	RAT_Reference VARCHAR(20) NULL, -- ID in 3rd-party excels etc.
	
	-- restrictions (optional)
	COD_CarTheme INT NULL,
	VEC_CarId INT NULL,
	COD_CarClass INT NULL,
	-- routing
	RAT_ForzaRouteId INT NULL, -- RAT_TrackId if based on Forza Standard Course
	RAT_CustomRoute VARCHAR(50) NULL, -- Name of custom route
	-- aditional properties
	RAT_Laps SMALLINT NOT NULL DEFAULT 1, -- FH4: 1..50
	COD_Season INT NULL,
	COD_TimeOfDay INT NULL,
	COD_Weather INT NULL,
	COD_TimeProgression INT NULL,
	-- more info
	RAT_DefaultLapTimeSec INT NULL, -- using given Car Class; what's considered good in a class? ext table...?
	RAT_DistanceKM FLOAT NULL,
	RAT_SharingCode INT NULL, -- FH ingame sharing code
	COD_Difficulty INT NULL,
	
	RAT_Description VARCHAR(1000) NULL	
)
;
CREATE INDEX NI1_RacingTrack ON RAT_RacingTrack (RAT_Name)
;
CREATE INDEX NI2_RacingTrack ON RAT_RacingTrack (RAT_SharingCode)
;

CREATE TABLE VEC_Vehicle
(
	VEC_CarId INT AUTO_INCREMENT PRIMARY KEY,
	VEC_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL,
	VEC_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT NULL,
	COD_Game INT NOT NULL,
	VEC_Rarity VARCHAR(10) NOT NULL,
	VEC_Year SMALLINT NOT NULL,
	VEC_Name VARCHAR(50) NOT NULL,
	VEC_Unlock VARCHAR(50) NOT NULL,
	VEC_Value INT NOT NULL,
	VEC_Speed FLOAT NOT NULL,
	VEC_Handling FLOAT NOT NULL,
	VEC_Acceleration FLOAT NOT NULL,
	VEC_Launch FLOAT NOT NULL,
	VEC_Breaking FLOAT NOT NULL,
	VEC_Performance VARCHAR(10) NOT NULL,
	VEC_Description VARCHAR(1000) NULL
);
CREATE INDEX NI1_Vehicle ON VEC_Vehicle (COD_Game, VEC_Name)
;

-- intersection VEC/COD:CarTheme
CREATE TABLE VTT_VehicleTypesThemes
(
	VTT_RowId INT AUTO_INCREMENT PRIMARY KEY,
	VEC_CarId INT NOT NULL,
	COD_CarTheme INT NOT NULL
);
CREATE UNIQUE INDEX UI1_VTT ON VTT_VehicleTypesThemes (VEC_CarId, COD_CarTheme)
;

CREATE TABLE CMP_Championship
(
	CMP_ChampionshipId INT AUTO_INCREMENT PRIMARY KEY,
	CMP_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL,
	CMP_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT NULL,
	COD_SharingMode INT NOT NULL, -- visibility
	
	COD_Game INT NOT NULL,
	CMP_Name VARCHAR(100) NOT NULL,
	CMP_Description VARCHAR(1000) NULL,
	
	-- rating calculated in view
	CMP_UpVotes SMALLINT NOT NULL DEFAULT 0,	
	CMP_DownVotes SMALLINT NOT NULL DEFAULT 0
)
;
CREATE INDEX NI_Championship1 ON CMP_Championship (CMP_Name)
;

CREATE TABLE RCE_Race
(
	RCE_RaceId INT AUTO_INCREMENT PRIMARY KEY,
	RCE_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL,
	RCE_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT NULL,
	
	CMP_ChampionshipId INT NOT NULL,
	RCE_RaceNo SMALLINT NOT NULL, -- order of events
	RAT_TrackId INT NOT NULL,
	
	-- restrictions
	COD_Series INT NULL,
	COD_CarTheme INT NULL,
	VEC_CarId INT NULL,
	COD_CarClass INT NULL,	
	
	-- conditions (inherited from course or changed)
	COD_Season INT NULL,
	COD_TimeOfDay INT NULL,
	COD_Weather INT NULL,
	COD_TimeProgression INT NULL	
)
;
CREATE UNIQUE INDEX UI_Race1 ON RCE_Race (CMP_ChampionshipId, RCE_RaceNo)
;
CREATE INDEX NI_Race1 ON RCE_Race (CMP_ChampionshipId)
;

-- up/down votes casted in RAV_RatingVote
CREATE TABLE CMT_Comment
(
	-- meta data
	CMT_RowId INT AUTO_INCREMENT PRIMARY KEY,
	CMT_Created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	USR_CreatedBy INT NOT NULL,
	CMT_Modified TIMESTAMP NULL,
	USR_ModifiedBy INT NULL,
	CMT_TableRef CHAR(3) NOT NULL, -- RAT, CMP
	CMT_RecordId INT NOT NULL, -- FK in referenced table
	-- payload
	CMT_Parent INT NULL,
	COD_Status INT NOT NULL, -- pending, blocked, public, deleted by creator
	CMT_Comment VARCHAR(1000) NOT NULL
)
;
CREATE INDEX NI_Comment1 ON CMT_Comment (CMT_TableRef, CMT_RecordId)
;

CREATE VIEW V_Votes as
	SELECT
		rav.RAV_TableRef,
		rav.RAV_RecordId,
		SUM(CASE rav.RAV_Vote WHEN 1 THEN 1 ELSE 0 END) AS RAV_UpVotes,
		SUM(CASE rav.RAV_Vote WHEN -1 THEN 1 ELSE 0 END) AS RAV_DownVotes
	FROM RAV_RatingVote rav
	GROUP BY
		rav.RAV_TableRef,
		rav.RAV_RecordId
;

CREATE VIEW V_Rating AS
	SELECT
		rav.*,
			rav.RAV_UpVotes + rav.RAV_DownVotes AS RAV_TotalVotes,
			COALESCE(ROUND((((RAV_UpVotes / (rav.RAV_UpVotes + rav.RAV_DownVotes)) * 4) + 1) * 2, 0) / 2, 0) AS RAV_Rating,
			(
				(rav.RAV_UpVotes + 1.9208) / (rav.RAV_UpVotes + rav.RAV_DownVotes) - 1.96 * SQRT((rav.RAV_UpVotes * rav.RAV_DownVotes) / (rav.RAV_UpVotes + rav.RAV_DownVotes) + 0.9604) / (rav.RAV_UpVotes + rav.RAV_DownVotes)
			) / (1 + 3.8416 / (rav.RAV_UpVotes + rav.RAV_DownVotes)) AS RAV_RatingSortOrder -- lowerBound
	FROM V_Votes rav
;

-- rating algoryhtm based on
-- https://onextrapixel.com/how-to-build-a-5-star-rating-system-with-wilson-interval-in-mysql/
CREATE VIEW V_RacingTrack AS
	SELECT
		rat.*,
		COALESCE(rating.RAV_UpVotes, 0) AS RAV_UpVotes,
		COALESCE(rating.RAV_DownVotes, 0) AS RAV_DownVotes,
		COALESCE(rating.RAV_TotalVotes, 0) AS RAV_TotalVotes,
		COALESCE(rating.RAV_Rating, 0) AS RAV_Rating,
		COALESCE(rating.RAV_RatingSortOrder, 0) AS RAV_RatingSortOrder
	FROM RAT_RacingTrack rat
	LEFT OUTER JOIN V_Rating rating
		ON  rating.RAV_TableRef = 'RAT'
		AND rating.RAV_RecordId = rat.RAT_TrackId
;

/*
Leider werden von MySQL keine Sub-Selects oder CTEs in Views unterstützt
CREATE VIEW V_RacingTrack as
SELECT
	base.*,
	COALESCE(ROUND((((base.RAT_UpVotes / base.RAT_TotalVotes) * 4) + 1) * 2, 0) / 2, 0) AS RAT_Rating
FROM (
	SELECT
		rat.*,
		rat.RAT_UpVotes + rat.RAT_DownVotes AS RAT_TotalVotes,
		(
			(rat.RAT_UpVotes + 1.9208) / (rat.RAT_UpVotes + rat.RAT_DownVotes) - 1.96 * SQRT((rat.RAT_UpVotes * rat.RAT_DownVotes) / (rat.RAT_UpVotes + rat.RAT_DownVotes) + 0.9604) / (rat.RAT_UpVotes + rat.RAT_DownVotes)
		) / (1 + 3.8416 / (rat.RAT_UpVotes + rat.RAT_DownVotes)) AS lowerBound -- ratingSortOrder
		
	FROM rat_racingtrack rat
) base
;
*/

CREATE VIEW V_Car as
	SELECT
		car.*,
		SUBSTR(VEC_Performance, 1, INSTR(VEC_Performance, ' ') - 1) AS VEC_Class,
		SUBSTR(VEC_Performance, INSTR(VEC_Performance, ' ')) AS VEC_Index	
	FROM VEC_Vehicle car
	;

-- helpers weil keine sub-selects/CTEs in views erlaubt
-- 1. Ausprägungen zählen und IDs auslesen
CREATE VIEW V_ChampionshipInfo1 as
	SELECT
		rce.CMP_ChampionshipId,
		MAX(rce.RCE_RaceNo) AS count_Races,
		-- einzelne Werte (Varianten) zählen für Text-Formatierung in View2
		COUNT(DISTINCT rce.COD_Series) AS count_Series,
		COUNT(DISTINCT rce.COD_CarTheme) AS count_CarTheme,	
		COUNT(DISTINCT rce.VEC_CarId) AS count_Car,
		COUNT(DISTINCT rce.COD_CarClass) AS count_CarClass,
		-- Codes/Autos werden in der zweiten View aufgelöst, basierend auf der Anzahl Werte
		MAX(rce.COD_Series) AS COD_Series,
		MAX(rce.COD_CarTheme) AS COD_CarTheme,
		MAX(rce.VEC_CarId) AS VEC_CarId,
		MAX(rce.COD_CarClass) AS COD_CarClass,
		-- für die spätere Sorierung
		MAX(COALESCE(rce.RCE_Modified, rce.RCE_Created)) AS RCE_LastAccessed
	FROM RCE_Race rce
	GROUP BY
		rce.CMP_ChampionshipId
;

-- 2. Codes/Referenzen auflösen
CREATE VIEW V_ChampionshipInfo2 as
	SELECT
		cmp.*,
		CONCAT(cmp.count_Races, ' ', txtRace.TXT_Text) AS TXT_Races,
		CASE cmp.count_Series
			WHEN 1 THEN cdSeries.COD_Text
			ELSE CONCAT(txtMixed.TXT_Text, ' ', txtSeries.TXT_Text)
		END AS TXT_Series,
		CASE cmp.count_CarTheme
			WHEN 1 THEN cdCarTheme.COD_Text
			ELSE CONCAT(txtMixed.TXT_Text, ' ', txtCarThemes.TXT_Text)
		END AS TXT_CarTheme,
		CASE cmp.count_Car
			WHEN 1 THEN vec.VEC_Name
			ELSE CONCAT(txtMixed.TXT_Text, ' ', txtCars.TXT_Text)
		END AS VEC_CarName,
		CASE cmp.count_CarClass
			WHEN 1 THEN cdCarClass.COD_Text
			ELSE CONCAT(txtMixed.TXT_Text, ' ', txtCarClasses.TXT_Text)
		END AS TXT_CarClass
	FROM V_ChampionshipInfo1 cmp
	JOIN TXT_TextTranslation txtRace
		ON  txtRace.TXT_TableRef = '***' -- not a table
		AND txtRace.TXT_ObjectId = CASE WHEN cmp.count_Races = 1 THEN 1 ELSE 2 END
		AND txtRace.COD_Language = 0	
	JOIN COD_CodeLookup cdSeries
		ON  cdSeries.COD_Domain = 'Series'
		AND cdSeries.COD_Value = cmp.COD_Series
		AND cdSeries.COD_Language = 0	
	JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = cmp.COD_CarTheme
		AND cdCarTheme.COD_Language = 0
	JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = cmp.COD_CarClass
		AND cdCarClass.COD_Language = 0
	JOIN TXT_TextTranslation txtMixed
		ON  txtMixed.TXT_TableRef = '***'
		AND txtMixed.TXT_ObjectId = 7
		AND txtMixed.COD_Language = 0
	JOIN TXT_TextTranslation txtSeries
		ON  txtSeries.TXT_TableRef = '***'
		AND txtSeries.TXT_ObjectId = 3
		AND txtSeries.COD_Language = 0
	JOIN TXT_TextTranslation txtCarThemes
		ON  txtCarThemes.TXT_TableRef = '***'
		AND txtCarThemes.TXT_ObjectId = 4
		AND txtCarThemes.COD_Language = 0
	JOIN TXT_TextTranslation txtCars
		ON  txtCars.TXT_TableRef = '***'
		AND txtCars.TXT_ObjectId = 5
		AND txtCars.COD_Language = 0	
	JOIN TXT_TextTranslation txtCarClasses
		ON  txtCarClasses.TXT_TableRef = '***'
		AND txtCarClasses.TXT_ObjectId = 6
		AND txtCarClasses.COD_Language = 0
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = cmp.VEC_CarId
;

CREATE VIEW V_Championship AS
	SELECT
		cmp.*,
		GREATEST(COALESCE(cmp.CMP_Modified, cmp.CMP_Created), info.RCE_LastAccessed) AS CMP_LastAccessed,
		info.count_Races,
		info.TXT_Races,
		info.count_Series,
		info.COD_Series,
		info.TXT_Series,
		info.count_CarTheme,
		info.COD_CarTheme,
		info.TXT_CarTheme,	
		info.count_Car,
		info.VEC_CarName,
		info.count_CarClass,
		info.COD_CarClass,
		info.TXT_CarClass,
		COALESCE(rating.RAV_UpVotes, 0) AS RAV_UpVotes,
		COALESCE(rating.RAV_DownVotes, 0) AS RAV_DownVotes,
		COALESCE(rating.RAV_TotalVotes, 0) AS RAV_TotalVotes,
		COALESCE(rating.RAV_Rating, 0) AS RAV_Rating,
		COALESCE(rating.RAV_RatingSortOrder, 0) AS RAV_RatingSortOrder
	FROM CMP_Championship cmp
	JOIN V_ChampionshipInfo2 info
		ON info.CMP_ChampionshipId = cmp.CMP_ChampionshipId
	LEFT OUTER JOIN V_Rating rating
		ON  rating.RAV_TableRef = 'CMP'
		AND rating.RAV_RecordId = cmp.CMP_ChampionshipId
;

-- Basis für:
-- Home Page (listContent) & Search (searchContent) --> PreviewComponent
-- Teaser (listNewews(?)) -- eigene Sortierung
-- (search üblicherweise via itemName)
-- (sortierung auf sortField_xxx)
-- !! limit must be applied in calling procedures (data cut at this place)
CREATE VIEW V_Search as
-- für die übersicht wird der sharing als formatiert zurückgeliefert,
-- dies weil die View verschiedene entitäten komibiniert (union)
-- (sonst als number, formatierung im client)
-- ACHTUNG: MySql (auf dem Hoster) unterstützt kenie Sub-Selects in Views!
	SELECT 
		rat.RAT_TrackId AS itemId,
		'track' AS itemType,
		rat.RAT_Name AS itemName,
		CONCAT('by ', rat.RAT_Designer) AS itemInfo1,
		
		-- an dieser stelle (content preview) muss die formatierung direkt
		-- in der DB erfolgen, da der client einen Objekt-dynamischen String
		-- erwartet. Im Track/Course-Service wird der Code als Zahl übergeben
		-- (damit sortiert werden kann) und im Client formatiert (custom pipe)
		case 
			when COALESCE(rat.RAT_SharingCode, 0) <= 0 then '(coming soon)'
		else
			CONCAT(
				SUBSTR(CAST(rat.RAT_SharingCode AS CHAR(9)), 1, 3), ' ',
				SUBSTR(CAST(rat.RAT_SharingCode AS CHAR(9)), 4, 3), ' ',
				SUBSTR(CAST(rat.RAT_SharingCode AS CHAR(9)), 7, 3)
			)
		end AS itemInfo2,
		COALESCE(rat.RAT_Modified, rat.RAT_Created) AS sortField_Access,
		rat.RAV_UpVotes AS upVotes,
		rat.RAV_DownVotes AS downVotes,
		rat.RAV_TotalVotes AS totalVotes,
		rat.RAV_Rating AS rating,
		rat.RAV_RatingSortOrder AS sortField_Rating, -- genauer als das Rating
		-- Bildauswahl im Client
		rat.COD_Series,
		rat.COD_CarClass,
		-- für die SP (Filterung)
		rat.COD_Sharing,
		rat.USR_CreatedBy
	FROM V_RacingTrack rat
	WHERE
		rat.COD_Type = 1 -- community courses
		/* für die SP
		(rat.COD_Sharing = 0) -- shared for all
		/*
		OR (rat.COD_Sharing = 1 AND currentUserRole > 0) -- shared for members
		OR ((rat.COD_Sharing = 2 AND rat.USR_CreatedBy = currentUser) or (currentUser.Role = 2)) -- not shared (still visible to admins)
		*/
	UNION
	SELECT
		cmp.CMP_ChampionshipId AS itemId,
		'championship' AS itemType,
		cmp.CMP_Name AS itemName,
		cmp.TXT_Races AS itemInfo1,
		CASE
			WHEN cmp.VEC_CarName IS NOT NULL THEN
				CONCAT(cmp.TXT_Series, ' - ', cmp.TXT_CarClass, ' - ', cmp.VEC_CarName)
			ELSE
			CONCAT(cmp.TXT_Series, ' - ', cmp.TXT_CarClass, ' - ', cmp.TXT_CarTheme)
		END AS itemInfo2,
		COALESCE(cmp.CMP_Modified, cmp.CMP_Created) AS sortField_Access,
		cmp.RAV_UpVotes AS upVotes,
		cmp.RAV_DownVotes AS downVotes,
		cmp.RAV_TotalVotes AS totalVotes,
		cmp.RAV_Rating AS rating,
		cmp.RAV_RatingSortOrder AS sortField_Rating, -- genauer als das Rating
		-- Bildauswahl im Client
		cmp.COD_Series,
		cmp.COD_CarClass,		
		-- für die SP (Filterung)
		cmp.COD_SharingMode AS COD_Sharing, -- inkonsequentes naming :-/
		cmp.USR_CreatedBy	
	FROM V_Championship cmp
;

-- Version mit Autos; momentan unbenutzt
/*
CREATE VIEW V_Search as
SELECT 
	'track' AS itemType,
	rat.RAT_Name AS itemName,
	coalesce(cdType.COD_Text, rat.COD_Type) AS itemInfo1,
	coalesce(cdSeries.COD_Text, rat.COD_Series) AS itemInfo2,
	0 AS itemRating
FROM RAT_RacingTrack rat
LEFT OUTER JOIN COD_CodeLookup cdType
	ON  cdType.COD_Domain = 'Track Type'
	AND cdType.COD_Value = rat.COD_Type
	AND cdType.COD_Language = 0 -- from header
LEFT OUTER JOIN COD_CodeLookup cdSeries
	ON  cdSeries.COD_Domain = 'Series'
	AND cdSeries.COD_Value = rat.COD_Series
	AND cdSeries.COD_Language = 0 -- from header
UNION
SELECT
	'car' AS itemType,
	VEC_Name AS itemName,
	VEC_Performance AS itemInfo1,
	VEC_Rarity AS itemInfo2,
	0 AS itemRating
FROM VEC_Vehicle
*/

-- es darf zwar nur einen Eintrag pro UserId in der MVF geben,
-- zur Sicherheit wird mit dieser View dennoch sichergestellt,
-- dass auch nur ein Record erscheint. Leider gibt es diverse
-- Limitierungen in  MySql (keine Sub-Queries in Views) sowie
-- keine OLAP-Funktionen, und  generell ein teilweise anderes
-- Verhalten bezüglich Funktionen und Group By.
CREATE VIEW V_User as
	SELECT
		usr.USR_UserId,
		COALESCE(usr.USR_XBoxTag, usr.USR_DiscordName, usr.USR_LoginName) AS USR_DisplayName,
		usr.USR_Created AS USR_Joined,
		usr.USR_LoginActive,
		usr.USR_LoginName,
		usr.USR_XBoxTag,
		usr.USR_DiscordName,
		usr.COD_Role,
		COALESCE(cdRole.COD_Text, usr.COD_Role) AS TXT_Role,
		usr.COD_Language,
		COALESCE(cdLanguage.COD_Text, usr.COD_Language) AS TXT_Language,
		usr.USR_LastSeen,
		MAX(mvfPP.MVF_FileName) AS MVF_ProfilePicture		
	FROM USR_User usr
	-- profile picture
	LEFT OUTER JOIN MVF_MultiValueFile mvfPP
		ON  mvfPP.MVF_TableRef = 'USR'
		AND mvfPP.MVF_RecordId = usr.USR_UserId
	LEFT OUTER JOIN COD_CodeLookup cdRole
		ON  cdRole.COD_Domain = 'Roles'
		AND cdRole.COD_Value = usr.COD_Role
		AND cdRole.COD_Language = 0 -- "sylang" (alternative SP mit #temp)
	LEFT OUTER JOIN COD_CodeLookup cdLanguage
		ON  cdLanguage.COD_Domain = 'Languages'
		AND cdLanguage.COD_Value = usr.COD_Language
		AND cdLanguage.COD_Language = 0 -- "sylang" (alternative SP mit #temp)
	GROUP BY
		usr.USR_UserId,
		COALESCE(usr.USR_XBoxTag, usr.USR_DiscordName, usr.USR_LoginName),
		usr.USR_Created,
		usr.USR_LoginActive,
		usr.USR_LoginName,
		usr.USR_XBoxTag,
		usr.USR_DiscordName,
		usr.COD_Role,
		COALESCE(cdRole.COD_Text, usr.COD_Role),
		usr.COD_Language,
		COALESCE(cdLanguage.COD_Text, usr.COD_Language),
		usr.USR_LastSeen
;

-- ToDo: Constrains/References


-- SPs require special delimiter; change temporarily
DELIMITER //

CREATE PROCEDURE listCodeTypes(
	IN cdLanguage INT
)
BEGIN
	SELECT
		COD_Domain,
		COD_Value,
		COD_Text
	FROM COD_CodeLookup
	WHERE
		COD_Language = cdLanguage
	ORDER BY
		COD_Domain,
		COD_Text;
END //

CREATE PROCEDURE createUser (
	IN loginName VARCHAR(50),
	IN pwd VARCHAR(255),
	IN xboxTag VARCHAR(50),
	IN discordName VARCHAR(50),
	IN cdLanguage INT
)
BEGIN
	INSERT INTO USR_User
	(USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Language)
	VALUES
	(1, LoginName, TRUE, pwd, xboxTag, discordName, cdLanguage);
END //

CREATE PROCEDURE existsUser(
	IN loginName VARCHAR(50),
	OUT userExists BOOLEAN
)  
BEGIN
	DECLARE cnt INT DEFAULT 0;
	
	SELECT COUNT(*) 
	INTO cnt
	FROM USR_User
	WHERE
		USR_LoginName = loginName;
	
	if cnt > 0 then
		SET userExists = TRUE;
	else
		SET userExists = FALSE;
	END if;	
END //

CREATE PROCEDURE loginUser (
	IN loginName VARCHAR(50)
)
BEGIN	
	-- komplexere Logik in eigener SP (z. B. "Active Now" im CLient)
	UPDATE USR_User
	SET
		USR_LastSeen = CURRENT_TIMESTAMP
	WHERE
		USR_LoginName = loginName;
		
	SELECT
		usr.USR_UserId,
		usr.USR_Created,
		usr.USR_Modified,
		usr.USR_LoginActive,
		usr.USR_Password,
		usr.USR_XBoxTag,
		usr.USR_DiscordName,
		usr.COD_Role,
		COALESCE(cdRole.COD_Text, usr.COD_Role) AS TXT_Role,
		usr.COD_Language,
		COALESCE(cdLanguage.COD_Text, usr.COD_Language) AS TXT_Language
	FROM USR_User usr
	LEFT OUTER JOIN COD_CodeLookup cdRole
		ON  cdRole.COD_Domain = 'Roles'
		AND cdRole.COD_Value = usr.COD_Role
		AND cdRole.COD_Language = usr.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdLanguage
		ON  cdLanguage.COD_Domain = 'Languages'
		AND cdLanguage.COD_Value = usr.COD_Language
		AND cdLanguage.COD_Language = usr.COD_Language
	WHERE
		USR_LoginName = loginName;		
END //

CREATE PROCEDURE readUser(
	IN userId INT,
	IN cdLanguage INT
)
BEGIN
	SELECT
		usr.USR_Created,
		usr.USR_Modified,
		usr.USR_LoginName,
		usr.USR_LoginActive,
		usr.COD_Role,
		COALESCE(cdRole.COD_Text, usr.COD_Role) AS TXT_Role,
		usr.COD_Language,
		COALESCE(cdLanguage.COD_Text, usr.COD_Language) AS TXT_Language,
		usr.USR_XBoxTag,
		usr.USR_DiscordName,
		usr.USR_LastSeen
	FROM USR_User usr
	LEFT OUTER JOIN COD_CodeLookup cdRole
		ON  cdRole.COD_Domain = 'Roles'
		AND cdRole.COD_Value = usr.COD_Role
		AND cdRole.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdLanguage
		ON  cdLanguage.COD_Domain = 'Languages'
		AND cdLanguage.COD_Value = usr.COD_Language
		AND cdLanguage.COD_Language = cdLanguage
	WHERE
		usr.USR_UserId = userId;
END //

CREATE PROCEDURE listUsers(
	IN cdLanguage INT 
)
BEGIN
	SELECT
		usr.USR_Created,
		usr.USR_Modified,
		usr.USR_LoginName,
		usr.USR_LoginActive,
		usr.USR_XBoxTag,
		usr.USR_DiscordName,
		usr.COD_Role,
		COALESCE(cdRole.COD_Text, usr.COD_Role) AS TXT_Role,
		usr.COD_Language,
		COALESCE(cdLanguage.COD_Text, usr.COD_Language) AS TXT_Language
	FROM USR_User usr
	LEFT OUTER JOIN COD_CodeLookup cdRole
		ON  cdRole.COD_Domain = 'Roles'
		AND cdRole.COD_Value = usr.COD_Role
		AND cdRole.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdLanguage
		ON  cdLanguage.COD_Domain = 'Languages'
		AND cdLanguage.COD_Value = usr.COD_Language
		AND cdLanguage.COD_Language = cdLanguage;		
END //

CREATE PROCEDURE listContent (
	IN username VARCHAR(50), -- ToDo: auf userId umstellen
	-- convention says language is passed via html header
	-- to redude database load
	IN cdLanguage INT
)
BEGIN
	-- used to enforce permissions
	DECLARE userId INT;
	DECLARE cdRole INT;
	
	SELECT
		USR_UserId,
		COD_Role
	INTO
		userId,
		cdRole
	FROM USR_User
	WHERE
		USR_LoginName = username;
	
	-- get actual data
	SELECT *
	FROM V_Search
	WHERE
		(COD_Sharing = 0) -- shared for all
		OR (COD_Sharing = 1 AND cdRole > 0) -- shared for members
		OR ((COD_Sharing = 2 AND USR_CreatedBy = userId) or (cdRole = 2)) -- not shared (still visible to admins)
	ORDER BY sortField_Rating, sortField_Access DESC
	LIMIT 6;
END //

CREATE PROCEDURE readTrack(
	IN trackId INT,
	IN cdLanguage INT,
	IN userId INT
)
BEGIN
	SELECT
		-- meta data
		rat.RAT_TrackId,
		rat.RAT_Created,
		rat.USR_CreatedBy,
		--usrCreated.USR_LoginName AS USR_CreatedByName,
		COALESCE(rat.RAT_Designer, usrCreated.USR_XBoxTag, usrCreated.USR_DiscordName, usrCreated.USR_LoginName) AS USR_CreatedByName,
		rat.RAT_Modified,
		rat.USR_ModifiedBy,
		usrModified.USR_LoginName AS USR_ModifiedByName,
		rat.COD_Sharing,
		COALESCE(cdSharing.COD_Text, rat.COD_Sharing) AS TXT_Sharing,
		-- std info
		rat.COD_Game,
		COALESCE(cdGame.COD_Text, rat.COD_Game) AS TXT_Game,
		coalesce(txtName.TXT_Text, rat.RAT_Name) AS RAT_Name, -- translatation outer join coalesce
		rat.COD_Type,
		COALESCE(cdType.COD_Text, rat.COD_Type) AS TXT_Type,
		rat.COD_Series,
		COALESCE(cdSeries.COD_Text, rat.COD_Series) AS TXT_Series,
		-- cst info block I (Felder sind nicht mehr gebraucht)
		rat.RAT_Designer,
		rat.RAT_Reference,
		-- restrictions
		rat.COD_CarTheme,
		COALESCE(cdCarTheme.COD_Text, rat.COD_CarTheme) AS TXT_CarTheme,
		rat.VEC_CarId, -- link ID for routing
		vec.VEC_Name as VEC_CarName,
		rat.COD_CarClass,
		COALESCE(cdCarClass.COD_Text, rat.COD_CarClass) as TXT_CarClass,
		-- routing
		rat.RAT_ForzaRouteId, -- join
		ratForzaRoute.RAT_Name as RAT_ForzaRouteName,
		rat.RAT_CustomRoute, -- internal name given
		-- cst info block II
		rat.RAT_Laps,
		rat.COD_Season,
		COALESCE(cdSeason.COD_Text, rat.COD_Season) AS TXT_Season,
		rat.COD_TimeOfDay,
		COALESCE(cdTimeOfDay.COD_Text, rat.COD_TimeOfDay) AS TXT_TimeOfDay,
		rat.COD_Weather,
		COALESCE(cdWeather.COD_Text, rat.COD_Weather) AS TXT_Weather,
		rat.COD_TimeProgression,
		COALESCE(cdTimeProgression.COD_Text, rat.COD_TimeProgression) AS TXT_TimeProgression,
		-- cst info block III
		rat.RAT_DefaultLapTimeSec,
		rat.RAT_DistanceKM,
		rat.RAT_SharingCode,
		rat.COD_Difficulty,
		COALESCE(cdDifficulty.COD_Text, rat.COD_Difficulty) AS TXT_Difficulty,
		rat.RAT_Description,
		-- rating
		rat.RAV_Rating,
		rat.RAV_UpVotes,
		rat.RAV_DownVotes,
		COALESCE(rav.RAV_Vote, 0) AS RAV_UserVote
	FROM V_RacingTrack rat
	JOIN USR_User usrCreated
		ON  usrCreated.USR_UserId = rat.USR_CreatedBy
	LEFT OUTER JOIN USR_User usrModified
		ON  usrModified.USR_UserId = rat.USR_ModifiedBy
	LEFT OUTER JOIN TXT_TextTranslation txtName
		ON  txtName.TXT_TableRef = 'RAT'
		AND txtName.TXT_ObjectId = rat.RAT_TrackId
		AND txtName.COD_Language = cdLanguage			
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = rat.VEC_CarId
	-- User's Rating Vote
	LEFT OUTER JOIN RAV_RatingVote rav
		ON  rav.RAV_TableRef = 'RAT'
		AND rav.RAV_RecordId = rat.RAT_TrackId
		AND rav.USR_UserId = userId		
	-- Codes
	LEFT OUTER JOIN COD_CodeLookup cdSharing
		ON  cdSharing.COD_Domain = 'Sharing'
		AND cdSharing.COD_Value = rat.COD_Sharing
		AND cdSharing.COD_Language = cdLanguage
	LEFT OUTER JOIN RAT_RacingTrack ratForzaRoute -- allenfalls TXTlang
		ON  ratForzaRoute.RAT_TrackId = rat.RAT_ForzaRouteId
	LEFT OUTER JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = rat.COD_CarTheme
		AND cdCarTheme.COD_Language = cdLanguage	
	LEFT OUTER JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = rat.COD_CarClass
		AND cdCarClass.COD_Language = cdLanguage		
	LEFT OUTER JOIN COD_CodeLookup cdGame
		ON  cdGame.COD_Domain = 'Games'
		AND cdGame.COD_Value = rat.COD_Game
		AND cdGame.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdType
		ON  cdType.COD_Domain = 'Track Type'
		AND cdType.COD_Value = rat.COD_Type
		AND cdType.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdSeries
		ON  cdSeries.COD_Domain = 'Series'
		AND cdSeries.COD_Value = rat.COD_Series
		AND cdSeries.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdSeason
		ON  cdSeason.COD_Domain = 'Season'
		AND cdSeason.COD_Value = rat.COD_Season
		AND cdSeason.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdTimeOfDay
		ON  cdTimeOfDay.COD_Domain = 'Day Time'
		AND cdTimeOfDay.COD_Value = rat.COD_TimeOfDay
		AND cdTimeOfDay.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdWeather
		ON  cdWeather.COD_Domain = 'Weather'
		AND cdWeather.COD_Value = rat.COD_Weather
		AND cdWeather.COD_Language = cdLanguage			
	LEFT OUTER JOIN COD_CodeLookup cdTimeProgression
		ON  cdTimeProgression.COD_Domain = 'Time Progression'
		AND cdTimeProgression.COD_Value = rat.COD_TimeProgression
		AND cdTimeProgression.COD_Language = cdLanguage		
	LEFT OUTER JOIN COD_CodeLookup cdDifficulty
		ON  cdDifficulty.COD_Domain = 'Track Difficulty'
		AND cdDifficulty.COD_Value = rat.COD_Difficulty
		AND cdDifficulty.COD_Language = cdLanguage		
	WHERE
		rat.RAT_TrackId = trackId;
END //

-- https://stackoverflow.com/questions/15896351/how-to-write-mysql-stored-procedure-using-like-operator
CREATE PROCEDURE searchCarNames(
	IN cdGame INT,
	IN searchTerm VARCHAR(20)
)
BEGIN
	-- Die Stammdaten sind nicht perfekt
	-- Verschiedene Jahrgänge eines Modells sind nicht gekennzeichnet
	SELECT
		MAX(VEC_CarId) AS VEC_CarId,
		VEC_Name
	FROM VEC_Vehicle
	WHERE
		COD_Game = 0
		AND VEC_Name LIKE CONCAT(searchTerm, '%')
	GROUP BY
		VEC_Name
	ORDER BY
		VEC_Name;
END //

CREATE PROCEDURE createTrack(
	IN userId INT,
	
	IN cdGame INT,
	IN courseName VARCHAR(50),
	IN cdType INT,
	IN cdSeries INT,
	
	IN cdSharing INT,
	IN designer VARCHAR(50),
	IN reference VARCHAR(20),
	
	IN cdCarTheme INT,
	IN carId INT,
	IN cdCarClass INT,
	
	IN forzaRouteId INT,
	IN customRoute VARCHAR(50),
	
	IN laps SMALLINT,
	IN cdSeason INT,
	IN cdTimeOfDay INT,
	IN cdWeather INT,
	IN cdTimeProgression INT,
	
	IN defaultLapTimeSec INT,
	IN distanceKM FLOAT,
	IN sharingCode INT,
	IN cdDifficulty INT,
	
	IN description VARCHAR(1000),
	
	OUT trackId INT
)
BEGIN
	INSERT INTO RAT_RacingTrack
	(
		USR_CreatedBy,
		
		COD_Game,
		RAT_Name,
		COD_Type,
		COD_Series,
		
		COD_Sharing,
		RAT_Designer,
		RAT_Reference,
		
		COD_CarTheme,
		VEC_CarId,
		COD_CarClass,
		
		RAT_ForzaRouteId,
		RAT_CustomRoute,
		
		RAT_Laps,
		COD_Season,
		COD_TimeOfDay,
		COD_Weather,
		COD_TimeProgression,
		
		RAT_DefaultLapTimeSec,
		RAT_DistanceKM,
		RAT_SharingCode,
		COD_Difficulty,
		
		RAT_Description
	)
	VALUES
	(
		userId,
		
		cdGame,
		courseName,
		cdType,
		cdSeries,
		
		cdSharing,
		designer,
		reference,
		
		cdCarTheme,
		carId,
		cdCarClass,
		
		forzaRouteId,
		customRoute,
		
		laps,
		cdSeason,
		cdTimeOfDay,
		cdWeather,
		cdTimeProgression,
		
		defaultLapTimeSec,
		distanceKM,
		sharingCode,
		cdDifficulty,
		
		description
	);
	
	SELECT LAST_INSERT_ID()
	INTO trackId;	
END //

CREATE PROCEDURE createMvcEntry(
	IN tableRef CHAR(3),
	IN recordId INT,
	IN codeType VARCHAR(20),
	IN cdValue INT
)
BEGIN
	INSERT INTO MVC_MultiValueCode
	(
		MVC_TableRef,
		MVC_RecordId,
		COD_Domain,
		COD_Value
	)
	VALUES
	(
		tableRef,
		recordId,
		codeType,
		cdValue
	);
END //

CREATE PROCEDURE listMvcEntries(
	IN tableRef CHAR(3),
	IN recordId INT,
	IN codeType VARCHAR(20)
)
BEGIN
	SELECT
		mvc.COD_Value,
		COALESCE(cdLookup.COD_Text, mvc.COD_Value) AS TXT_Value
	FROM MVC_MultiValueCode mvc
	LEFT OUTER JOIN COD_CodeLookup cdLookup
		ON  cdLookup.COD_Domain = mvc.COD_Domain
		AND cdLookup.COD_Value = mvc.COD_Value
	WHERE
		mvc.MVC_TableRef = tableRef
		AND mvc.MVC_RecordId = recordId
		AND mvc.COD_Domain = codeType
	ORDER BY
		TXT_Value;
END //

CREATE PROCEDURE deleteMvcEntries(
	IN tableRef CHAR(3),
	IN recordId INT,
	IN codeType VARCHAR(20)
)
BEGIN
	DELETE
	FROM MVC_MultiValueCode
	WHERE
		MVC_TableRef = tableRef
		AND MVC_RecordId = recordId
		AND COD_Domain = codeType;
END //

CREATE PROCEDURE createMvfEntry(
	IN userId INT,
	IN tableRef CHAR(3),
	IN recordId INT,
	IN fileName VARCHAR(50),
	IN original VARCHAR(50),
	IN description VARCHAR(50)
)
BEGIN
	INSERT INTO MVF_MultiValueFile
	(
		USR_CreatedBy,
		MVF_TableRef,
		MVF_RecordId,
		MVF_FileName,
		MVF_Original,
		MVF_Description
	)
	VALUES
	(
		userId,
		tableRef,
		recordId,
		fileName,
		original,
		description
	);
END //

CREATE PROCEDURE listMvfEntries(
	IN tableRef CHAR(3),
	IN recordId INT
)
BEGIN
	SELECT
		mvf.MVF_RowId, -- used as handle to remove entries
		mvf.USR_CreatedBy,
		-- client display (order: xBox->discord->login)
		usrCreated.USR_LoginName,
		usrCreated.USR_XBoxTag,
		usrCreated.USR_DiscordName,
		mvf.MVF_Uploaded,
		mvf.MVF_FileName, -- used to build URL response
		mvf.MVF_Original,
		mvf.MVF_Description
	FROM MVF_MultiValueFile mvf
	JOIN USR_User usrCreated
		ON usrCreated.USR_UserId = mvf.USR_CreatedBy
	WHERE
		mvf.MVF_TableRef = tableRef
		AND mvf.MVF_RecordId = recordId
	ORDER BY
		mvf.MVF_Uploaded DESC;
END //

-- can't use aliases for DELETE statements in MySql :-/
CREATE PROCEDURE deleteMvfEntry(
	IN fileId INT
)
BEGIN
	DELETE
	FROM MVF_MultiValueFile
	WHERE
		MVF_RowId = fileId;
END //

CREATE PROCEDURE deleteMvfEntries(
	IN tableRef CHAR(3),
	IN recordId INT
)
BEGIN
	DELETE
	FROM MVF_MultiValueFile
	WHERE
		MVF_TableRef = tableRef
		AND MVF_RecordId = recordId;
END //

CREATE PROCEDURE readFileName(
	IN fileId INT
)
BEGIN
	SELECT MVF_FileName
	FROM MVF_MultiValueFile
	WHERE
		MVF_RowId = fileId;
END //

CREATE PROCEDURE readVote(
	IN tableRef CHAR(3),
	IN recordId INT,
	IN userId INT
)
BEGIN
	SELECT
		rav.RAV_Vote
	FROM RAV_RatingVote rav
	WHERE
		rav.RAV_TableRef = tableRef
		AND rav.RAV_RecordId = recordId
		AND rav.USR_UserId = userId;
END //

CREATE PROCEDURE readRating(
	IN tableRef CHAR(3),
	IN recordId INT
)
BEGIN
SELECT
	rav.RAV_UpVotes,
	rav.RAV_DownVotes,
	rav.RAV_TotalVotes,
	rav.RAV_Rating
FROM V_Rating rav
WHERE
	rav.RAV_TableRef = tableRef
	AND rav.RAV_RecordId = recordId;
END //

CREATE PROCEDURE countUserVotes(
	IN userId INT
)
BEGIN
	SELECT COUNT(*) AS count_Votes
	FROM rav_ratingvote
	WHERE
		USR_UserId = userId;
END //

/*
CREATE PROCEDURE listImageURLs(
	IN tableRef CHAR(3),
	IN objectId INT
)
BEGIN 
	SELECT
		img.IMG_Uploaded,		
		CONCAT(
			LOWER(img.IMG_TableRef),
			'_', img.IMG_ObjectId,
			'_', img.IMG_OrderNum, '.', SUBSTRING_INDEX(img.RAT_OriginalFileName, '.',  -1)
		) AS IMG_Locator,
		img.IMG_Description
	FROM IMG_ImageURL img
	WHERE
		img.IMG_TableRef = tableRef
		AND img.IMG_ObjectId = objectId
	ORDER BY
		img.IMG_Uploaded DESC;
END //
*/

CREATE PROCEDURE updateTrack(
	IN trackId INT,
	IN userId INT,
	
	IN cdGame INT,
	IN courseName VARCHAR(50),
	
	IN cdSharing INT,
	IN reference VARCHAR(20),
	
	IN cdCarTheme INT,
	IN carId INT,
	IN cdCarClass INT,
	
	IN forzaRouteId INT,
	IN customRoute VARCHAR(50),
	
	IN laps SMALLINT,
	IN cdSeason INT,
	IN cdTimeOfDay INT,
	IN cdWeather INT,
	IN cdTimeProgression INT,
	
	IN defaultLapTimeMin SMALLINT,
	IN distanceKM SMALLINT,
	IN sharingCode INT,
	IN cdDifficulty INT,
	
	IN description VARCHAR(1000)	
)
BEGIN
	UPDATE RAT_RacingTrack
		set
			RAT_Modified = CURRENT_TIMESTAMP,
			USR_ModifiedBy = userId,
			
			COD_Game = cdGame,
			RAT_Name = courseName,
			
			COD_Sharing = cdSharing,
			RAT_Reference = reference,
			
			COD_CarTheme = cdCarTheme,
			VEC_CarID = carId,
			COD_CarClass = cdCarClass,
			
			RAT_ForzaRouteId = forzaRouteId,
			RAT_CustomRoute = customRoute,
			
			RAT_Laps = laps,
			COD_Season = cdSeason,
			COD_TimeOfDay = cdTimeOfDay,
			COD_Weather = cdWeather,
			COD_TimeProgression = cdTimeProgression,
			
			RAT_DefaultLapTimeMin = defaultLapTimeMin,
			RAT_DistanceKM = distanceKM,
			RAT_SharingCode = sharingCode,
			COD_Difficulty = cdDifficulty,
			
			RAT_Description = description
	WHERE
		RAT_TrackId = trackId;
END //

CREATE PROCEDURE createChampionship(
	IN userId INT,
	IN cdSharingMode INT,
	
	IN cdGame INT,
	IN blueprintName VARCHAR(100),
	IN description VARCHAR(1000),
	
	OUT championshipId INT
)
BEGIN
	INSERT INTO CMP_Championship
	(USR_CreatedBy, COD_Game, CMP_Name, CMP_Description)
	VALUES
	(userId, cdGame, blueprintName, description);
	
	SELECT LAST_INSERT_ID()
	INTO championshipId;
END //

CREATE PROCEDURE createRace(
	IN userId INT,
	
	IN championshipId INT,
	IN raceNo INT,
	IN trackId INT,
	
	IN cdSeries INT,
	IN cdCarTheme INT,
	IN carId INT,
	IN cdCarClass INT,
	
	IN cdSeason INT,
	IN cdTimeOfDay INT,
	IN cdWeather INT,
	IN cdTimeProgression INT,
	
	OUT raceId INT
)
BEGIN
	INSERT INTO RCE_Race
	(
		USR_CreatedBy,
		
		CMP_ChampionshipId,
		RCE_RaceNo,
		RAT_TrackId,
		
		COD_Series,
		COD_CarTheme,
		VEC_CarId,
		COD_CarClass,
		
		COD_Season,
		COD_TimeOfDay,
		COD_Weather,
		COD_TimeProgression
	)
	VALUES
	(
		userId,
		
		championshipId,
		raceNo,
		trackId,
		
		cdSeries,
		cdCarTheme,
		carId,
		cdCarClass,
		
		cdSeason,
		cdTimeOfDay,
		cdWeather,
		cdTimeProgression
	);
	
	SELECT LAST_INSERT_ID()
	INTO raceId;
END //

CREATE PROCEDURE searchTrackNames(
	IN cdGame INT,
	IN searchTerm VARCHAR(20)
)
BEGIN
	SELECT
		rat.RAT_TrackId,
		rat.COD_Type,
		rat.COD_Series,
		rat.RAT_Name,
		rat.COD_CarClass,
		rat.COD_CarTheme,
		rat.VEC_CarId,
		vec.VEC_Name as VEC_CarName
	FROM RAT_RacingTrack rat
	LEFT OUTER JOIN VEC_Vehicle vec
		ON  vec.VEC_CarId = rat.VEC_CarId
	WHERE
		rat.COD_Game = cdGame
		AND rat.RAT_Name LIKE CONCAT(searchTerm, '%')
	ORDER BY
		rat.RAT_Name;
END //

CREATE PROCEDURE searchCustomTrackNames(
	IN cdGame INT,
	IN searchTerm VARCHAR(20)
)
BEGIN
	SELECT
		rat.RAT_TrackId,
		rat.COD_Type,
		rat.COD_Series,
		rat.RAT_Name,
		rat.COD_CarClass,
		rat.COD_CarTheme,
		rat.VEC_CarId,
		vec.VEC_Name as VEC_CarName
	FROM RAT_RacingTrack rat
	LEFT OUTER JOIN VEC_Vehicle vec
		ON  vec.VEC_CarId = rat.VEC_CarId
	WHERE
		rat.COD_Game = cdGame
		AND rat.COD_Type = 1
		AND rat.RAT_Name LIKE CONCAT(searchTerm, '%')
	ORDER BY
		rat.RAT_Name;
END //

CREATE PROCEDURE searchStandardTrackNames(
	IN cdGame INT,
	IN searchTerm VARCHAR(20)
)
BEGIN
	SELECT
		rat.RAT_TrackId,
		rat.COD_Type,
		rat.COD_Series,
		rat.RAT_Name,
		rat.COD_CarClass,
		rat.COD_CarTheme,
		rat.VEC_CarId,
		vec.VEC_Name as VEC_CarName
	FROM RAT_RacingTrack rat
	LEFT OUTER JOIN VEC_Vehicle vec
		ON  vec.VEC_CarId = rat.VEC_CarId
	WHERE
		rat.COD_Game = cdGame
		AND rat.COD_Type = 0
		AND rat.RAT_Name LIKE CONCAT(searchTerm, '%')
	ORDER BY
		rat.RAT_Name;
END //

CREATE PROCEDURE readChampionship(
	IN championshipId INT,
	IN cdLanguage INT,
	IN userId INT
)
BEGIN
	SELECT
		-- meta data
		cmp.CMP_ChampionshipId,
		cmp.CMP_Created,
		cmp.USR_CreatedBy,
		COALESCE(usrCreated.USR_XBoxTag, usrCreated.USR_DiscordName, usrCreated.USR_LoginName) AS USR_CreatedByName,
		cmp.CMP_Modified,
		cmp.USR_ModifiedBy,
		COALESCE(usrModified.USR_XBoxTag, usrModified.USR_DiscordName, usrModified.USR_LoginName) AS USR_ModifiedByName,
		cmp.COD_SharingMode,
		COALESCE(cdSharingMode.COD_Text, cmp.COD_SharingMode) AS TXT_SharingMode,
		-- payload
		cmp.COD_Game,
		COALESCE(cdGame.COD_Text, cmp.COD_Game) AS TXT_Game,
		cmp.CMP_Name,
		cmp.CMP_Description,
		cmp.count_Races,
		-- rating
		cmp.RAV_Rating,
		cmp.RAV_UpVotes,
		cmp.RAV_DownVotes,
		COALESCE(rav.RAV_Vote, 0) AS RAV_UserVote
	FROM V_Championship cmp
	JOIN USR_User usrCreated
		ON  usrCreated.USR_UserId = cmp.USR_CreatedBy
	-- User's Rating Vote
	LEFT OUTER JOIN RAV_RatingVote rav
		ON  rav.RAV_TableRef = 'CMP'
		AND rav.RAV_RecordId = cmp.CMP_ChampionshipId
		AND rav.USR_UserId = userId
	LEFT OUTER JOIN USR_User usrModified
		ON  usrModified.USR_UserId = cmp.USR_ModifiedBy
	-- Codes
	LEFT OUTER JOIN COD_CodeLookup cdSharingMode
		ON  cdSharingMode.COD_Domain = 'Sharing'
		AND cdSharingMode.COD_Value = cmp.COD_SharingMode
		AND cdSharingMode.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdGame
		ON  cdGame.COD_Domain = 'Games'
		AND cdGame.COD_Value = cmp.COD_Game
		AND cdGame.COD_Language = cdLanguage
	where
		cmp.CMP_ChampionshipId = championshipId;
END //

CREATE PROCEDURE listRaces(
	IN championshipId INT,
	IN cdLanguage INT
)
BEGIN
	SELECT
		-- meta data			
		rce.RCE_RaceId,
		rce.RCE_Created,
		rce.USR_CreatedBy,
		COALESCE(usrCreated.USR_XBoxTag, usrCreated.USR_DiscordName, usrCreated.USR_LoginName) AS USR_CreatedByName,
		rce.RCE_Modified,
		rce.USR_ModifiedBy,
		COALESCE(usrModified.USR_XBoxTag, usrModified.USR_DiscordName, usrModified.USR_LoginName) AS USR_ModifiedByName,
		-- payload
		rce.RCE_RaceNo,
		rce.RAT_TrackId,
		rat.RAT_Name AS RAT_TrackName,
		-- restrictions (inherit/override from custom tracks)
		rce.COD_Series AS COD_Series,
		COALESCE(cdSeries.COD_Text, rce.COD_Series) AS TXT_Series,
		rce.COD_CarTheme AS COD_CarTheme,
		COALESCE(cdCarTheme.COD_Text, rce.COD_CarTheme) AS TXT_CarTheme,			
		rce.VEC_CarId AS VEC_CarId,
		vec.VEC_Name AS VEC_CarName,			
		rce.COD_CarClass AS COD_CarClass,
		COALESCE(cdCarClass.COD_Text, rce.COD_CarClass) AS TXT_CarClass,
		-- conditions (inherit/override from custom tracks)
		rce.COD_Season AS COD_Season,
		COALESCE(cdSeason.COD_Text, rce.COD_Season) AS TXT_Season,
		rce.COD_TimeOfDay AS COD_TimeOfDay,
		COALESCE(cdTimeOfDay.COD_Text, rce.COD_TimeOfDay) AS TXT_TimeOfDay,
		rce.COD_Weather AS COD_Weather,
		COALESCE(cdWeather.COD_Text, rce.COD_Weather) AS TXT_Weather,
		rce.COD_TimeProgression AS COD_TimeProgression,
		COALESCE(cdTimeProgression.COD_Text, rce.COD_TimeProgression) AS TXT_TimeProgression
	FROM RCE_Race rce
	JOIN USR_User usrCreated
		ON  usrCreated.USR_UserId = rce.USR_CreatedBy
	LEFT OUTER JOIN USR_User usrModified
		ON  usrModified.USR_UserId = rce.USR_ModifiedBy
	LEFT OUTER JOIN RAT_RacingTrack rat
		ON rat.RAT_TrackId = rce.RAT_TrackId
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = rce.VEC_CarId
	-- Codes
	LEFT OUTER JOIN COD_CodeLookup cdSeries
		ON  cdSeries.COD_Domain = 'Series'
		AND cdSeries.COD_Value = rce.COD_Series
		AND cdSeries.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = rce.COD_CarTheme
		AND cdCarTheme.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = rce.COD_CarClass
		AND cdCarClass.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdSeason
		ON  cdSeason.COD_Domain = 'Season'
		AND cdSeason.COD_Value = rce.COD_Season
		AND cdSeason.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdTimeOfDay
		ON  cdTimeOfDay.COD_Domain = 'Day Time'
		AND cdTimeOfDay.COD_Value = rce.COD_TimeOfDay
		AND cdTimeOfDay.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdWeather
		ON  cdWeather.COD_Domain = 'Weather'
		AND cdWeather.COD_Value = rce.COD_Weather
		AND cdWeather.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdTimeProgression
		ON  cdTimeProgression.COD_Domain = 'Time Progression'
		AND cdTimeProgression.COD_Value = rce.COD_TimeProgression
		AND cdTimeProgression.COD_Language = cdLanguage	
	WHERE
		rce.CMP_ChampionshipId = championshipId
	ORDER by
		rce.RCE_RaceNo;
END //

CREATE PROCEDURE updateVote(
	IN tableRef CHAR(3),
	IN recordId INT,
	IN userId INT,
	IN vote SMALLINT
)
BEGIN
	DELETE
	FROM RAV_RatingVote
	WHERE
		RAV_TableRef = tableRef
		AND RAV_RecordId = recordId
		AND USR_UserId = userId;
		
	-- do not record withdraws
	IF (vote <> 0) THEN
		INSERT INTO RAV_RatingVote
		(RAV_TableRef, RAV_RecordId, USR_UserId, RAV_Vote)
		values
		(tableRef, recordId, userId, vote);
	END IF;
END //

-- language look-up moved to SP for newer implementations ;-)
CREATE PROCEDURE listTracks(
	IN userId INT
)
BEGIN
	SELECT
		-- basic info
		rat.RAT_TrackId,
		COALESCE(txtName.TXT_Text, rat.RAT_Name) AS RAT_Name,
		rat.RAT_SharingCode,
		rat.RAV_Rating,
		rat.COD_Type,
		COALESCE(cdGame.COD_Text, rat.COD_Game) AS TXT_Game,
		rat.COD_Type,
		COALESCE(cdType.COD_Text, rat.COD_Type) AS TXT_Type,
		rat.RAT_Designer, -- filled by AddTrack API??
		rat.COD_Difficulty,
		COALESCE(cdDifficulty.COD_Text, rat.COD_Difficulty) AS TXT_Difficulty,
		-- Terrain?
		-- restrictions
		rat.COD_Series,
		COALESCE(cdSeries.COD_Text, rat.COD_Series) AS TXT_Series,
		rat.COD_CarClass,
		COALESCE(cdCarClass.COD_Text, rat.COD_CarClass) as TXT_CarClass,
		rat.COD_CarTheme,
		COALESCE(cdCarTheme.COD_Text, rat.COD_CarTheme) AS TXT_CarTheme,
		vec.VEC_CarId,
		vec.VEC_Name as VEC_CarName,
		-- conditions
		rat.COD_Season,
		COALESCE(cdSeason.COD_Text, rat.COD_Season) AS TXT_Season,
		rat.COD_Weather,
		COALESCE(cdWeather.COD_Text, rat.COD_Weather) AS TXT_Weather,
		rat.COD_TimeOfDay,
		COALESCE(cdTimeOfDay.COD_Text, rat.COD_TimeOfDay) AS TXT_TimeOfDay,
		rat.COD_TimeProgression,
		COALESCE(cdTimeProgression.COD_Text, rat.COD_TimeProgression) AS TXT_TimeProgression,
		rat.RAV_RatingSortOrder
	FROM V_RacingTrack rat
	-- enforce permissions
	JOIN USR_User usrCurrent
		ON usrCurrent.USR_UserId = userId
	LEFT OUTER JOIN TXT_TextTranslation txtName
		ON  txtName.TXT_TableRef = 'RAT'
		AND txtName.TXT_ObjectId = rat.RAT_TrackId
		AND txtName.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = rat.VEC_CarId		
	-- Codes
	LEFT OUTER JOIN COD_CodeLookup cdGame
		ON  cdGame.COD_Domain = 'Games'
		AND cdGame.COD_Value = rat.COD_Game
		AND cdGame.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdType
		ON  cdType.COD_Domain = 'Track Type'
		AND cdType.COD_Value = rat.COD_Type
		AND cdType.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdDifficulty
		ON  cdDifficulty.COD_Domain = 'Track Difficulty'
		AND cdDifficulty.COD_Value = rat.COD_Difficulty
		AND cdDifficulty.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdSeries
		ON  cdSeries.COD_Domain = 'Series'
		AND cdSeries.COD_Value = rat.COD_Series
		AND cdSeries.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = rat.COD_CarClass
		AND cdCarClass.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = rat.COD_CarTheme
		AND cdCarTheme.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdSeason
		ON  cdSeason.COD_Domain = 'Season'
		AND cdSeason.COD_Value = rat.COD_Season
		AND cdSeason.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdWeather
		ON  cdWeather.COD_Domain = 'Weather'
		AND cdWeather.COD_Value = rat.COD_Weather
		AND cdWeather.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdTimeOfDay
		ON  cdTimeOfDay.COD_Domain = 'Day Time'
		AND cdTimeOfDay.COD_Value = rat.COD_TimeOfDay
		AND cdTimeOfDay.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdTimeProgression
		ON  cdTimeProgression.COD_Domain = 'Time Progression'
		AND cdTimeProgression.COD_Value = rat.COD_TimeProgression
		AND cdTimeProgression.COD_Language = usrCurrent.COD_Language
	WHERE
		-- custom tracks (blueprints) only
		(rat.COD_Type = 1)
		-- enforce visibility permissions
		AND (
			(rat.COD_Sharing = 0) -- shared for all
			OR (rat.COD_Sharing = 1 AND usrCurrent.COD_Role > 0) -- shared for members
			OR ((rat.COD_Sharing = 2 AND rat.USR_CreatedBy = usrCurrent.USR_UserId) or (usrCurrent.COD_Role = 2)) -- not shared (still visible to admins)
		)
	ORDER by
		rat.RAV_RatingSortOrder DESC,
		rat.RAT_Name ASC
	LIMIT 50;
END //

CREATE PROCEDURE countChampionships(
	IN userId INT,
	OUT cnt INT
)
BEGIN
	DECLARE cdRole INT DEFAULT 0; -- guest
	
	-- get role of current user to enforce visibility
	SELECT COD_Role
	INTO cdRole
	FROM USR_User
	WHERE
		USR_UserId = userId;

	SELECT COUNT(*)
	INTO cnt
	FROM cmp_championship cmp
	WHERE
		(cmp.COD_SharingMode = 0) -- shared for all
		OR (cmp.COD_SharingMode = 1 AND cdRole > 0) -- shared for members
		OR ((cmp.COD_SharingMode = 2 AND cmp.USR_CreatedBy = userId) or (cdRole = 2)); -- not shared (still visible to admins)
END //

CREATE PROCEDURE listChampionships(
	IN userId INT
)
BEGIN
	SELECT
		cmp.CMP_ChampionshipId,
		cmp.CMP_Name,
		cmp.RAV_Rating,
		cmp.count_Races,
		cmp.count_Series,
		cmp.COD_Series,
		cmp.TXT_Series,
		cmp.count_CarClass,
		cmp.COD_CarClass,
		cmp.TXT_CarClass,
		cmp.count_CarTheme,
		cmp.COD_CarTheme,
		cmp.TXT_CarTheme,
		cmp.count_Car,
		cmp.VEC_CarName,
		cmp.USR_CreatedBy,
		COALESCE(usrCreated.USR_XBoxTag, usrCreated.USR_DiscordName, usrCreated.USR_LoginName) AS USR_CreatedByName
	FROM V_Championship cmp
	-- enforce permissions
	JOIN USR_User usrCurrent
		ON usrCurrent.USR_UserId = userId
	JOIN USR_User usrCreated
		ON  usrCreated.USR_UserId = cmp.USR_CreatedBy
	-- enforce visibility permissions		
	WHERE
		(cmp.COD_SharingMode = 0) -- shared for all
		OR (cmp.COD_SharingMode = 1 AND usrCurrent.COD_Role > 0) -- shared for members
		OR ((cmp.COD_SharingMode = 2 AND cmp.USR_CreatedBy = usrCurrent.USR_UserId) or (usrCurrent.COD_Role = 2)) -- not shared (still visible to admins)
	ORDER BY
		cmp.RAV_RatingSortOrder DESC,
		coalesce(cmp.CMP_Modified, cmp.CMP_Created) desc
	LIMIT 50;
END //

CREATE PROCEDURE searchCustomTracks(
	IN userId INT,
	IN cdGame INT,
	IN searchTerm VARCHAR(50)
)
BEGIN
	SELECT
		-- basic info
		rat.RAT_TrackId,
		COALESCE(txtName.TXT_Text, rat.RAT_Name) AS RAT_Name,
		rat.RAT_SharingCode,
		rat.RAV_Rating,
		rat.COD_Type,
		COALESCE(cdGame.COD_Text, rat.COD_Game) AS TXT_Game,
		rat.COD_Type,
		COALESCE(cdType.COD_Text, rat.COD_Type) AS TXT_Type,
		rat.RAT_Designer, -- filled by AddTrack API??
		rat.COD_Difficulty,
		COALESCE(cdDifficulty.COD_Text, rat.COD_Difficulty) AS TXT_Difficulty,
		-- Terrain?
		-- restrictions
		rat.COD_Series,
		COALESCE(cdSeries.COD_Text, rat.COD_Series) AS TXT_Series,
		rat.COD_CarClass,
		COALESCE(cdCarClass.COD_Text, rat.COD_CarClass) as TXT_CarClass,
		rat.COD_CarTheme,
		COALESCE(cdCarTheme.COD_Text, rat.COD_CarTheme) AS TXT_CarTheme,
		vec.VEC_CarId,
		vec.VEC_Name as VEC_CarName,
		-- conditions
		rat.COD_Season,
		COALESCE(cdSeason.COD_Text, rat.COD_Season) AS TXT_Season,
		rat.COD_Weather,
		COALESCE(cdWeather.COD_Text, rat.COD_Weather) AS TXT_Weather,
		rat.COD_TimeOfDay,
		COALESCE(cdTimeOfDay.COD_Text, rat.COD_TimeOfDay) AS TXT_TimeOfDay,
		rat.COD_TimeProgression,
		COALESCE(cdTimeProgression.COD_Text, rat.COD_TimeProgression) AS TXT_TimeProgression,
		rat.RAV_RatingSortOrder
	FROM V_RacingTrack rat
	-- enforce permissions
	JOIN USR_User usrCurrent
		ON usrCurrent.USR_UserId = userId
	LEFT OUTER JOIN TXT_TextTranslation txtName
		ON  txtName.TXT_TableRef = 'RAT'
		AND txtName.TXT_ObjectId = rat.RAT_TrackId
		AND txtName.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = rat.VEC_CarId		
	-- Codes
	LEFT OUTER JOIN COD_CodeLookup cdGame
		ON  cdGame.COD_Domain = 'Games'
		AND cdGame.COD_Value = rat.COD_Game
		AND cdGame.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdType
		ON  cdType.COD_Domain = 'Track Type'
		AND cdType.COD_Value = rat.COD_Type
		AND cdType.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdDifficulty
		ON  cdDifficulty.COD_Domain = 'Track Difficulty'
		AND cdDifficulty.COD_Value = rat.COD_Difficulty
		AND cdDifficulty.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdSeries
		ON  cdSeries.COD_Domain = 'Series'
		AND cdSeries.COD_Value = rat.COD_Series
		AND cdSeries.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = rat.COD_CarClass
		AND cdCarClass.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = rat.COD_CarTheme
		AND cdCarTheme.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdSeason
		ON  cdSeason.COD_Domain = 'Season'
		AND cdSeason.COD_Value = rat.COD_Season
		AND cdSeason.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdWeather
		ON  cdWeather.COD_Domain = 'Weather'
		AND cdWeather.COD_Value = rat.COD_Weather
		AND cdWeather.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdTimeOfDay
		ON  cdTimeOfDay.COD_Domain = 'Day Time'
		AND cdTimeOfDay.COD_Value = rat.COD_TimeOfDay
		AND cdTimeOfDay.COD_Language = usrCurrent.COD_Language
	LEFT OUTER JOIN COD_CodeLookup cdTimeProgression
		ON  cdTimeProgression.COD_Domain = 'Time Progression'
		AND cdTimeProgression.COD_Value = rat.COD_TimeProgression
		AND cdTimeProgression.COD_Language = usrCurrent.COD_Language
	WHERE
		(rat.COD_Game = cdGame)
		-- custom tracks (blueprints) only
		AND (rat.COD_Type = 1)
		-- enforce visibility permissions
		AND (
			(rat.COD_Sharing = 0) -- shared for all
			OR (rat.COD_Sharing = 1 AND usrCurrent.COD_Role > 0) -- shared for members
			OR ((rat.COD_Sharing = 2 AND rat.USR_CreatedBy = usrCurrent.USR_UserId) or (usrCurrent.COD_Role = 2)) -- not shared (still visible to admins)
		)
		-- search criteria
		AND (
			(rat.RAT_Name LIKE CONCAT('%', searchTerm, '%'))
			OR (CAST(rat.RAT_SharingCode AS CHAR(9)) LIKE CONCAT('%', searchTerm, '%'))
			OR (CAST(rat.RAV_Rating AS CHAR(6)) LIKE CONCAT('%', searchTerm, '%'))
			
			OR (cdGame.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdDifficulty.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdSeries.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdCarClass.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdCarTheme.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (vec.VEC_Name LIKE CONCAT('%', searchTerm, '%'))
			OR (cdSeason.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdWeather.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdTimeOfDay.COD_Text LIKE CONCAT('%', searchTerm, '%'))
			OR (cdTimeProgression.COD_Text LIKE CONCAT('%', searchTerm, '%'))
		)
	ORDER BY
		rat.RAT_Name ASC
	LIMIT 50;
END //	

CREATE PROCEDURE int_searchChampionships(
	IN cdLanguage INT
)
BEGIN
	CREATE TEMPORARY TABLE srch_cmp
	SELECT
		cmp.CMP_ChampionshipId,
		cmp.COD_Game,
		cmp.COD_SharingMode, -- applied by outer SP
		cmp.CMP_Name,
		cmp.RAV_Rating,
		cmp.RAV_RatingSortOrder,
		cmp.count_Races,
		cmp.count_Series,
		cmp.COD_Series,
		cmp.TXT_Series,
		cmp.count_CarClass,
		cmp.COD_CarClass,
		cmp.TXT_CarClass,
		cmp.count_CarTheme,
		cmp.COD_CarTheme,
		cmp.TXT_CarTheme,
		cmp.count_Car,
		cmp.VEC_CarName,
		cmp.USR_CreatedBy,
		cmp.CMP_LastAccessed,
		COALESCE(usrCreated.USR_XBoxTag, usrCreated.USR_DiscordName, usrCreated.USR_LoginName) AS USR_CreatedByName,
		-- used internally for search in SP - not sent to client
		rat.RAT_Name AS srch_TrackName,
		COALESCE(cdSeries.COD_Text, rat.COD_Series) AS srch_Series,
		COALESCE(cdCarClass.COD_Text, rat.COD_CarClass) as srch_CarClass,
		COALESCE(cdCarTheme.COD_Text, rat.COD_CarTheme) AS srch_CarTheme,
		vec.VEC_Name AS srch_CarName
	FROM V_Championship cmp
	JOIN USR_User usrCreated
		ON  usrCreated.USR_UserId = cmp.USR_CreatedBy
	-- make race infos searchable (by string aggregation)
	JOIN RCE_Race rce
		ON rce.CMP_ChampionshipId = cmp.CMP_ChampionshipId
	JOIN RAT_RacingTrack rat
		ON rat.RAT_TrackId = rce.RAT_TrackId
	LEFT OUTER JOIN COD_CodeLookup cdSeries
			ON  cdSeries.COD_Domain = 'Series'
			AND cdSeries.COD_Value = rce.COD_Series
			AND cdSeries.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdCarClass
		ON  cdCarClass.COD_Domain = 'Car Class'
		AND cdCarClass.COD_Value = rce.COD_CarClass
		AND cdCarClass.COD_Language = cdLanguage
	LEFT OUTER JOIN COD_CodeLookup cdCarTheme
		ON  cdCarTheme.COD_Domain = 'Car Theme'
		AND cdCarTheme.COD_Value = rce.COD_CarTheme
		AND cdCarTheme.COD_Language = cdLanguage
	LEFT OUTER JOIN VEC_Vehicle vec
		ON vec.VEC_CarId = rce.VEC_CarId;
END //

CREATE PROCEDURE searchChampionships(
	IN userId INT,
	IN cdGame INT,
	IN searchTerm VARCHAR(50)
)
BEGIN
	DECLARE cdLanguage INT DEFAULT 0; -- english
	DECLARE cdRole INT DEFAULT 0; -- guest
	
	SELECT 
		COD_Language, COD_Role
	INTO cdLanguage, cdRole
	FROM USR_User
	where
		USR_UserId = userId;
	
	CALL int_searchChampionships(cdLanguage);
	
	SELECT DISTINCT
		cmp.CMP_ChampionshipId,
		cmp.CMP_Name,
		cmp.RAV_Rating,
		cmp.count_Races,
		cmp.count_Series,
		cmp.COD_Series,
		cmp.TXT_Series,
		cmp.count_CarClass,
		cmp.COD_CarClass,
		cmp.TXT_CarClass,
		cmp.count_CarTheme,
		cmp.COD_CarTheme,
		cmp.TXT_CarTheme,
		cmp.count_Car,
		cmp.VEC_CarName,
		cmp.USR_CreatedBy,
		USR_CreatedByName
	FROM srch_cmp cmp
	WHERE
		(cmp.COD_Game = cdGame)
		-- enforce visibility permissions
		AND (
			(cmp.COD_SharingMode = 0) -- shared for all
			OR (cmp.COD_SharingMode = 1 AND cdRole > 0) -- shared for members
			OR ((cmp.COD_SharingMode = 2 AND cmp.USR_CreatedBy = userId) or (cdRole = 2)) -- not shared (still visible to admins)
		)
		-- search criteria
		AND (
			(cmp.CMP_Name LIKE CONCAT('%', searchTerm, '%'))
			OR (CAST(cmp.RAV_Rating AS CHAR(6)) LIKE CONCAT('%', searchTerm, '%'))
			OR (CAST(cmp.count_Races AS CHAR(2)) LIKE CONCAT('%', searchTerm, '%'))
			-- fields that could contain "mixed..."
			OR (cmp.TXT_Series LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.TXT_CarClass LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.TXT_CarTheme LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.VEC_CarName LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.USR_CreatedByName LIKE CONCAT('%', searchTerm, '%'))
			-- racing fields
			OR (cmp.srch_Series LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.srch_CarClass LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.srch_CarTheme LIKE CONCAT('%', searchTerm, '%'))
			OR (cmp.srch_CarName LIKE CONCAT('%', searchTerm, '%'))
		)
	ORDER BY
		cmp.RAV_RatingSortOrder desc, cmp.CMP_LastAccessed DESC, cmp.CMP_Name ASC;
		
	DROP TABLE srch_cmp;		
END //

-- used for in-app passwords checks after login (eg. change password)
CREATE PROCEDURE readPassword(
	IN userId INT
)
BEGIN
	SELECT           
		USR_Password  
	FROM USR_User usr
	WHERE            
		usr.USR_UserId = userId;
END //

CREATE PROCEDURE updatePassword(
	IN userId INT,
	IN newPwd VARCHAR(255)
)
BEGIN
	UPDATE USR_User
	SET
		USR_Password = newPwd
	WHERE
		USR_UserId = userId;
END //

-- allow changes of the "profile-part" fields only
-- ("user" object is system-owned and may not be changed)
CREATE PROCEDURE updateUser(
	IN userId INT,
	IN xBoxTag VARCHAR(50),
	IN discordName VARCHAR(50)
)
BEGIN
	UPDATE USR_User
	SET
		USR_XBoxTag = xBoxTag,
		USR_DiscordName = discordName
	WHERE
		USR_UserId = userId;
END //

CREATE PROCEDURE deleteTrack(
	IN trackId INT
)
BEGIN
	DELETE
	FROM RAT_RacingTrack
	WHERE
		RAT_TrackId = trackId;
END //

CREATE PROCEDURE createComment(
	IN userId INT,
	IN tableRef CHAR(3),
	IN recordId INT,
	IN parentId INT,
	IN cdStatus INT,
	IN commentText VARCHAR(1000),
	OUT id INT
)
BEGIN
	INSERT INTO CMT_Comment
	(USR_CreatedBy, CMT_TableRef, CMT_RecordId, CMT_Parent, COD_Status, CMT_Comment)
	VALUES
	(userId, tableRef, recordId, parentId, cdStatus, commentText);
	
	SELECT LAST_INSERT_ID()
	INTO id;
END //

CREATE PROCEDURE listComments(
	IN userId INT,
	IN tableRef CHAR(3),
	IN recordId INT
)
BEGIN
	SELECT
		cmt.CMT_RowId,
		cmt.CMT_Created,
		usrCreated.USR_UserId AS USR_CreatedBy,
		usrCreated.USR_DisplayName AS USR_CreatedByName,		
		usrCreated.MVF_ProfilePicture,
		cmt.CMT_Modified,
		usrModified.USR_UserId AS USR_ModifiedBy,
		usrModified.USR_DisplayName AS USR_ModifiedByName,
		cmt.CMT_Parent,
		cmt.COD_Status,
		COALESCE(cdStatus.COD_Text, cmt.COD_Status) AS TXT_Status,
		-- do not return "soft-deleted" comments, but notify about the measure
		CASE cmt.COD_Status
			WHEN 3 THEN COALESCE(cdStatus.COD_Text, cmt.COD_Status)
			ELSE cmt.CMT_Comment
		END AS CMT_Comment,
		COALESCE(cvt.RAV_UpVotes, 0) AS RAV_UpVotes,
		COALESCE(cvt.RAV_DownVotes, 0) AS RAV_DownVotes,
		COALESCE(rav.RAV_Vote, 0) AS RAV_UserVote
	FROM CMT_Comment cmt
	-- apply current user's language
	JOIN USR_User usrCurrent
		ON  usrCurrent.USR_UserId = userId
	JOIN V_User usrCreated
		ON  usrCreated.USR_UserId = cmt.USR_CreatedBy
	-- creator or administrator
	LEFT OUTER JOIN V_User usrModified
		ON  usrModified.USR_UserId = cmt.USR_ModifiedBy
	-- total votes
	LEFT OUTER JOIN V_Votes cvt
		ON  cvt.RAV_TableRef = 'CMT'
		AND cvt.RAV_RecordId = cmt.CMT_RowId
	-- user's vote
	LEFT OUTER JOIN RAV_RatingVote rav
		ON  rav.RAV_TableRef = 'CMT'
		AND rav.RAV_RecordId = cmt.CMT_RowId
		AND rav.USR_UserId = userId	
	LEFT OUTER JOIN COD_CodeLookup cdStatus
		ON  cdStatus.COD_Domain = 'Comment Status'
		AND cdStatus.COD_Value = cmt.COD_Status
		AND cdStatus.COD_Language = usrCurrent.COD_Language
	WHERE
		cmt.CMT_TableRef = tableRef
		AND cmt.CMT_RecordId = recordId
	ORDER BY
		cmt.CMT_Created DESC,
		cmt.CMT_Parent

	LIMIT 100;
END //

CREATE PROCEDURE updateComment(
	IN userId INT,
	IN tableRef CHAR(3),
	IN recordId INT,
	IN cdStatus INT, -- possibly "pending" (0)
	IN commentText VARCHAR(1000)
)
BEGIN
	UPDATE CMT_Comment
	SET
		CMT_Modified = CURRENT_TIMESTAMP,
		USR_ModifiedBy = userId,
		COD_Status = cdStatus,
		CMT_Comment = commentText
	WHERE
		CMT_TableRef = tableRef
		AND CMT_RecordId = recordId;
END //

-- actually "soft-delete" (usually by creator)
-- admin user see admin_deleteComment (toDo)
CREATE PROCEDURE deleteComment(
	IN userId INT, -- currently not used
	IN id INT
)
BEGIN
	UPDATE CMT_Comment
	SET
		COD_Status = 3 -- deleted by user
	WHERE
		CMT_RowId = id;
END //

CREATE PROCEDURE readVoting(
	IN userId INT,
	IN tableRef CHAR(3),
	IN recordId INT
)
BEGIN
	SELECT
		vts.*,
		COALESCE(rav.RAV_Vote, 0) AS RAV_UserVote
	FROM V_Votes vts
	-- User's Rating Vote
	LEFT OUTER JOIN RAV_RatingVote rav
		ON  rav.RAV_TableRef = vts.RAV_TableRef
		AND rav.RAV_RecordId = vts.RAV_RecordId
		AND rav.USR_UserId = userId
	WHERE
		vts.RAV_TableRef = tableRef
		AND vts.RAV_RecordId = recordId;
END //

DELIMITER ;

-- more SPs...

-- Add Data
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_Password, COD_Role) VALUES (1, 'SYSTEM', '', 2);

-- DEV USER
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Role) VALUES (1, 'roger', TRUE, '$2y$10$yMM5GRaWOR/cWgyn2kxuju5.kbqPk.H.5VPzCUWOh3Gw8Cbcz9o12', 'genevatouring', 'genevatouring', 2);
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Role) VALUES (1, 'guest', TRUE, '$2y$10$yMM5GRaWOR/cWgyn2kxuju5.kbqPk.H.5VPzCUWOh3Gw8Cbcz9o12', 'guestDiscord', 'guestXbox', 0);
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Role) VALUES (1, 'member1', TRUE, '$2y$10$yMM5GRaWOR/cWgyn2kxuju5.kbqPk.H.5VPzCUWOh3Gw8Cbcz9o12', 'member1Discord', 'member1Xbox', 1);
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Role) VALUES (1, 'member2', TRUE, '$2y$10$yMM5GRaWOR/cWgyn2kxuju5.kbqPk.H.5VPzCUWOh3Gw8Cbcz9o12', 'member2Discord', 'member2Xbox', 1);
INSERT INTO USR_User (USR_CreatedBy, USR_LoginName, USR_LoginActive, USR_Password, USR_XBoxTag, USR_DiscordName, COD_Role) VALUES (1, 'admin2', TRUE, '$2y$10$yMM5GRaWOR/cWgyn2kxuju5.kbqPk.H.5VPzCUWOh3Gw8Cbcz9o12', 'admin2Discord', 'admin2XBox', 2);

-- Generator Code (enums)
-- SELECT CONCAT(raw.ctLabel, ' = ', '''', raw.ctName, ''',') AS typeLabel FROM (SELECT DISTINCT REPLACE(COD_Domain, ' ', '') as ctLabel, COD_Domain AS ctName FROM COD_CodeLookup ORDER BY COD_Domain) raw
-- SELECT CONCAT(REPLACE(regexp_replace(COD_Text, '[^A-Za-z0-9 ]', ''), ' ', ''), ',') AS valueLabel FROM COD_CodeLookup WHERE COD_Domain = 'Car Theme' ORDER BY COD_Value

-- code values must start at 0 (enums in client)
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Languages', 0, 0, 'English');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Languages', 1, 0, 'German');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Languages', 0, 1, 'Englisch');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Languages', 1, 1, 'Deutsch');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 0, 0, 'Guest (read-only)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 1, 0, 'Member (post content)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 2, 0, 'Administrator (full access)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 0, 1, 'Gast (read-only)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 1, 1, 'Mitglied (kann veröffentlichen)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Roles', 2, 1, 'Administrator (full access)');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 0, 0, 'FH4');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 1, 0, 'FH3');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 2, 0, 'FM7');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 0, 1, 'FH4');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 1, 1, 'FH3');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Games', 2, 1, 'FM7');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 0, 0, 'visible to all');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 1, 0, 'visible to members');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 2, 0, 'not shared');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 0, 1, 'für alle sichtbar');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 1, 1, 'nür für Mitglieder sichtbar');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Sharing', 2, 1, 'nicht geteilt');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Series', 1, 0, 'Road Racing');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Series', 2, 0, 'Dirt Racing');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Series', 3, 0, 'Cross Country');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Series', 4, 0, 'Street Scene');

-- used to pick/display championships that can be "mixed"
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Series', 0, 0, 'mixed');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Series', 1, 0, 'Road Racing');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Series', 2, 0, 'Dirt Racing');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Series', 3, 0, 'Cross Country');
-- INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Series', 4, 0, 'Street Scene');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 0, 0, 'mixed');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 1, 0, '? OPEN'); -- all classes
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 2, 0, 'D 500');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 3, 0, 'C 600');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 4, 0, 'B 700');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 5, 0, 'A 800');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 6, 0, 'S1 900');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 7, 0, 'S2 998');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Championship Car Class', 8, 0, 'X 999');

-- "real" entities (used in selections)
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 0, 0, 'all classes'); -- anything goes / ? OPEN
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 1, 0, 'D 500');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 2, 0, 'C 600');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 3, 0, 'B 700');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 4, 0, 'A 800');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 5, 0, 'S1 900');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 6, 0, 'S2 998');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Class', 7, 0, 'X 999');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 0, 0, 'anything goes');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 1, 0, 'Modern Super Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 2, 0, 'Retro Super Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 3, 0, 'Hyper Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 4, 0, 'Retro Saloons');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 5, 0, 'Vans & Utility');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 6, 0, 'Retro Sports Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 7, 0, 'Modern Sports Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 8, 0, 'Super Saloons');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 9, 0, 'Classic Racers');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 10, 0, 'Cult Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 11, 0, 'Rare Classics');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 12, 0, 'Hot Hatch');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 13, 0, 'Retro Hot Hatch');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 14, 0, 'Super Hot Hatch');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 15, 0, 'Extreme Track Toys');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 16, 0, 'Classic Muscle');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 17, 0, 'Rods and Customs');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 18, 0, 'Retro Muscle');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 19, 0, 'Modern Muscle');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 20, 0, 'Retro Rally');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 21, 0, 'Classic Rally');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 22, 0, 'Rally Monsters');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 23, 0, 'Modern Rally');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 24, 0, 'GT Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 25, 0, 'Super GT');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 26, 0, 'Extreme Offroad');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 27, 0, 'Sports Utility Heroes');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 28, 0, 'Offroad');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 29, 0, 'Offroad Buggies');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 30, 0, 'Classic Sports Cars');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 31, 0, 'Track Toys');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 32, 0, 'Vintage Racers');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 33, 0, 'Trucks');
-- based on UranDieb Excel
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 34, 0, 'La Corsa Italiana');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 35, 0, 'German Performance');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 36, 0, 'Vive la France');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 37, 0, 'Rule Britannia');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 38, 0, 'AMG vs M Sport');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Car Theme', 39, 0, 'Spezial');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Season', 0,  0, 'Spring');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Season', 1,  0, 'Summer');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Season', 2,  0, 'Automn');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Season', 3,  0, 'Winter');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Type', 0,  0, 'Standard');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Type', 1,  0, 'Community');

-- community track difficulties (do not confuse with drivatar/game difficulty)
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Difficulty', 0,  0, 'Very Easy');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Difficulty', 1,  0, 'Easy');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Difficulty', 2,  0, 'Medium');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Difficulty', 3,  0, 'Hard');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Track Difficulty', 4,  0, 'Very Hard');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 0,  0, '(currrent)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 1,  0, 'dawn');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 2,  0, 'sunrise');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 3,  0, 'morning');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 4,  0, 'early afternoon');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 5,  0, 'late afternoon');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 6,  0, 'sunset');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 7,  0, 'evening');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Day Time', 8,  0, 'night');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 0,  0, '(currrent)');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 1,  0, 'clear');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 2,  0, 'clear post-rain');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 3,  0, 'cloudy');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 4,  0, 'cloudy post-rain');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 5,  0, 'overcast');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 6,  0, 'light rain');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 7,  0, 'heavy rain');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Weather', 8,  0, 'fog');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Time Progression', 0,  0, 'rolling');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Time Progression', 1,  0, 'fixed');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Terrain', 0,  0, 'road');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Terrain', 1,  0, 'dirt');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Terrain', 2,  0, 'offroad');

INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Comment Status', 0,  0, 'pending');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Comment Status', 1,  0, 'released');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Comment Status', 2,  0, 'blocked');
INSERT INTO COD_CodeLookup (COD_Domain, COD_Value, COD_Language, COD_Text) VALUES ('Comment Status', 3,  0, 'deleted by user');

-- according to https://forums.forzamotorsport.net/turn10_postsm976461_Event-race-List.aspx
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Village Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Astmoor Heritage Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Bamburgh Coast Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Cotswolds Super Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Broadway Village Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'THE COLOSSUS', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Derwent Lakeside Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Derwent Reservoir Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Edinburgh Station Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Edinburgh City Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Elmsdon on Sea Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Glen Rannoch Hillside Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'THE GOLIATH', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Greendale Club Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Greendale Super Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Holyrood Park Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Horizon Festival Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Horizon Festival Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lake District Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lakehurst Copse Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lakehurst Forest Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'The Meadows Sprint', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Moorhead Wind Farm Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Princess Street Gardens Circuit', 0, 1);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Waterhead Sprint', 0, 1);

INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ashbrook Loop Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Astmoor Rally Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Bamburgh Pinewood Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Broadway Village Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Cotswolds Road Rally Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Derwent water Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Derwent Reservoir Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'THE GAUNTLET', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Glen Rannoch Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Greendale Foothills Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Highland Farm Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Holyrood Park Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lakehurst Forest Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lakehurst Woodland Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Moorhead Rally Trail', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Mortimer Gardens Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Mudkickers'' 4x4 Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Tarn Hows Scramble', 0, 2);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'White Horse Hill Trail', 0, 2);

INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Aerodrome Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Loop Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Rush Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Arthur''s Seat Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Beach View Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Castle Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'City Outskirts Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Coastal Rush Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Gardens Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Glen Rannoch Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Mountain Foot Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'North City Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Quarry Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Rail Yard Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'The Ridge Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Riverbank Cross Country Circuit', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'THE TITAN', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Whitewater Falls Cross Country', 0, 3);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Windmill Cross Country', 0, 3);

-- Street Scene removed from Racing App
/*
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ambleside Ascent', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Ashbrook Apex', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Batham Gate', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Broadway Crossfire', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Coastal Charge', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Derwent Valley Dash', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Edinburgh Stockbridge', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Edinburgh New Town', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Edinburgh West End', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Glenfinnan Chase', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'The Highland Charge', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Holyrood Run', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Lakehurst Rush', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'THE MARATHON', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Mortimer''s Pass', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'The Monument Wynds', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'North Coast Rush', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Otleydale Dash', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Railyard Express', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Reservoir Run', 0, 4);
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, RAT_Name, COD_Type, COD_Series) VALUES (1, 0, 'Wind Farm Rush', 0, 4);
*/

-- set all standard tracks to "open/all classes"
UPDATE RAT_RacingTrack
SET
	COD_CarClass = 0
WHERE
	COD_Type = 0
;

-- translations of event names
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text)
SELECT
	'RAT' AS TXT_TableRef,
	RAT_TrackId,
	0 AS COD_Language,
	RAT_Name
FROM RAT_RacingTrack
;

INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 1, 0, 'Race');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 2, 0, 'Races');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 1, 1, 'Rennen');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 2, 1, 'Rennen');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 3, 0, 'Series');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 4, 0, 'Car Themes');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 5, 0, 'Cars');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 6, 0, 'Classes');
INSERT INTO TXT_TextTranslation (TXT_TableRef, TXT_ObjectId, COD_Language, TXT_Text) VALUES ('***', 7, 0, 'mixed');

INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2017,'Abarth 124 Spider','Autoshow',43500,6,5.9,5.6,7.6,5.4,'C 577');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1968,'Abarth 595 esseesse','Autoshow',35000,3.9,4,3.7,4.9,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2016,'Abarth 695 Biposto','Autoshow',48000,5.7,6.3,5.9,7.5,6.4,'B 607');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1980,'Abarth Fiat 131','Autoshow',38000,5.5,4.7,5.5,7.1,4.5,'D 449');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2001,'Acura Integra Type-R','Autoshow',25000,6.3,5.8,5.6,6.9,5.4,'C 596');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2002,'Acura RSX Type-S','Autoshow',25000,6.3,5.8,5.6,6.7,5.4,'C 588');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Acura NSX','Autoshow',170000,7.4,7.6,9.6,10,8.3,'S1 850');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Alfa Romeo 4C','Autoshow',74000,6.6,7.1,6.5,8.8,7,'A 770');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2007,'Alfa Romeo 8C Competizione','Autoshow',300000,7.5,6.6,6.6,8.2,6.8,'A 777');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2007,'Alfa Romeo 8C Competizione F.E.','Wheelspin reward',550000,7.6,9.1,8.3,9.6,9.6,'S1 899');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1968,'Alfa Romeo 33 Stradale','Autoshow',10000000,6.9,5.8,6.9,8.6,5.5,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1965,'Alfa Romeo Giulia Sprint GTA Stradale','Autoshow',300000,5.1,4.6,5.4,6.9,4.5,'D 432');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,'Alfa Romeo Giulia TZ2','Autoshow',2500000,6.3,5.7,5.8,7,5.1,'B 639');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Alfa Romeo Giulia Quadrifoglio','Autoshow',120000,7.7,7.2,6.9,8.5,7.9,'A 795');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2017,'Alfa Romeo Giulia Quadrifoglio F.E.','Wheelspin reward',370000,8.7,8.1,7.6,9.1,8.7,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1934,'Alfa Romeo P3','Purchase: Edinburgh Castle',10000000,6.6,5,5.6,7.1,4.9,'B 626');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Alfa Romeo Stelvio Quadrifoglio','DLC: Car Pass',80000,7.2,5.9,9,10,6.3,'A 752');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Alpine A110','Hard-to-Find: Festival reward',250000,6.7,7,6.9,8.5,6.9,'A 740');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Alumiaft Class 10 Race Car','Autoshow',100000,5.3,6.5,6.6,7.9,6.2,'B 673');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2015,'Alumiaft Class 10 Race Car F.E.','Wheelspin reward',350000,6,6.6,7.7,9.2,6.8,'A 800');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1973,'AMC Gremlin X','Autoshow',35000,5,4.4,5.2,6.6,4.4,'D 394');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1971,'AMC Javelin AMX','Autoshow',35000,5.4,4.5,5.2,6.6,4.2,'C 512');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'AMC Rebel ''The Machine''','Hard-to-Find: Festival reward',250000,5.9,4.6,5.3,6.8,4.4,'C 541');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2554,'AMG Transport Dynamics M12S Warthog CST','Autoshow',850000,5.2,7.1,9.7,10,7.5,'A 756');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2018,'Apollo Intensa Emozione','Hard-to-Find: Festival reward',1050000,7.9,10,8.3,9.6,10,'S2 984');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Ariel Atom 500 V8','HL: Speed Zone Hero - Tier 11',108000,7,10,8.6,9.8,10,'S2 970');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Ariel Nomad','Autoshow',93000,6,6.3,7.6,9.2,6.1,'A 732');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Ascari KZ1R','Autoshow',240000,7.9,8.6,7.4,8.6,8.9,'S1 866');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1960,'Aston Martin DB4 GT Zagato','Barn Find',500000,6.9,5.4,4.6,5.1,4.6,'B 619');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1964,'Aston Martin DB5','Autoshow',800000,6.2,4.7,5.6,7.1,4.3,'C 534');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Aston Martin DB11','Autoshow',300000,7.8,7.1,6.8,8.4,7.6,'S1 810');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Aston Martin DB11 Preorder Car','Pre-Order bonus / Forzathon Shop',300000,8.9,8.2,6.7,8.3,8.7,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1958,'Aston Martin DBR1','Autoshow',10000000,7.1,5.6,5.3,6.1,5.1,'B 688');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'Aston Martin DBS Superleggera','Hard-to-Find: Festival reward',250000,8.2,7.4,6.9,8.5,8.1,'S1 853');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2010,'Aston Martin One-77','Autoshow',1400000,8.3,7.5,7.1,8.7,8,'S1 863');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Aston Martin V12 Vantage S','Autoshow',240000,8.2,6.9,6.6,8.2,7.4,'S1 814');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Aston Martin Vanquish Zagato CoupÃ©','Hard-to-Find: Festival reward',250000,7.8,7.3,6.9,8.5,8,'S1 824');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Aston Martin Vantage','DLC: Car Pass',400000,7.5,7.5,6.9,8.6,7.9,'S1 822');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'Aston Martin Vanquish','Autoshow',348000,7.9,7,6.7,8.3,7.5,'S1 802');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Aston Martin Vantage GT12','Autoshow',400000,7.2,8.4,6.9,8.5,9.1,'S1 846');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Aston Martin Vulcan','Autoshow',1500000,8.1,10,7.5,9,10,'S2 954');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Aston Martin Vulcan AMR Pro','Hard-to-Find: Festival reward',1500000,7.7,10,7.5,9,10,'S2 954');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2016,'Aston Martin Vulcan F.E.','Wheelspin reward',1750000,8.1,10,7.5,9,10,'S2 955');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'ATS GT','Hard-to-Find: Festival reward',250000,8.3,8,7.7,9.2,8.6,'S1 894');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1986,'Audi #2 Audi Sport quattro S1','Autoshow',375000,6.9,8,9.5,8,8.1,'S1 850');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Audi R8 CoupÃ© V10 plus 5.2 FSI quattro','Autoshow',290000,7.8,7.2,8.5,9.5,7.7,'S1 824');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Audi R8 V10 plus','Autoshow',242000,8.2,7.5,9.1,9.9,8.1,'S1 856');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1995,'Audi RS 2 Avant','Autoshow',50000,6.7,5.3,6.6,8.7,5.2,'B 616');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2011,'Audi RS 3 Sportback','Autoshow',42000,6.7,6.1,6.8,8.9,6.3,'B 699');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2006,'Audi RS 4','Autoshow',53000,7.5,6.2,7.5,8.9,6.2,'A 729');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2001,'Audi RS 4 Avant','Autoshow',94000,7.1,6,7.1,9,5.5,'B 695');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Audi RS 4 Avant','Autoshow',83000,7.5,6.2,7,8.7,6.7,'A 750');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Audi RS 5 CoupÃ©','Autoshow',88000,7.3,6.5,7.3,9,7,'A 750');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2003,'Audi RS 6','Autoshow',105000,7.4,5.9,6.7,8.4,5.8,'A 710');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2009,'Audi RS 6','Autoshow',155000,8,6.2,7.6,9.1,6.7,'A 743');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Audi RS 6 Avant','Autoshow',150000,7.8,6.2,8.8,10,6.7,'A 778');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Audi RS 7 Sportback','Autoshow',225000,8,6.1,8.3,9.9,6.5,'A 761');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2015,'Audi S1','Autoshow',35000,6.3,6.3,6.8,8.7,6.6,'B 679');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1983,'Audi Sport quattro','Barn Find',175000,6.4,5.2,7.1,8.8,5.2,'B 621');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2010,'Audi TT RS CoupÃ©','Wheelspin reward',66000,7.2,6.3,7.3,9.2,6.2,'A 722');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2015,'Audi TTS CoupÃ©','Autoshow',52000,7.4,6.4,7.3,9,5.8,'A 740');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1964,'Austin FX4 Taxi','HL: Isha''s Taxis - Tier 10',20000,4.5,3.8,3.6,4.5,3.5,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1965,'Austin-Healey 3000 MkIII','Autoshow',50000,5.7,4,5.1,6.5,3.6,'D 326');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1958,'Austin-Healey Sprite MkI','Autoshow',20000,4.3,4,3.9,5.6,3.7,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1939,'Auto Union Type D','Autoshow',10000000,8.7,5.1,6,7.3,4.6,'B 692');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'BAC Mono','Autoshow',160000,6.8,10,7.5,9,10,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1931,'Bentley 4-1/2 Liter Supercharged','Barn Find',10000000,4.8,3.7,4,5.9,3.7,'D 200');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1931,'Bentley 8-Liter','Autoshow',1500000,4.8,3.7,4.7,5.8,3.7,'D 175');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Bentley Bentayga','Autoshow',180000,7.5,6.1,7.6,9.4,6.3,'A 758');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Bentley Continental GT Speed','Autoshow',242000,8,6.3,7.8,9.5,6.7,'A 774');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2013,'Bentley Continental GT Speed F.E.','Wheelspin reward',492000,7.4,9.4,8.1,9.5,10,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Bentley Continental Supersports','Autoshow',200000,8,6.3,9.2,10,7,'A 798');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'BMW 1 Series M Coupe','Autoshow',55000,7,6.4,6.4,8,6.4,'A 731');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1973,'BMW 2002 Turbo','Autoshow',26000,5.8,4.6,5.5,5.9,4.5,'D 500');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'BMW i8','Autoshow',140000,7.7,6.6,9,10,6.6,'A 785');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'BMW i8 Roadster','DLC: Car Pass',150000,7.6,6.4,8.5,10,6.4,'A 776');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1957,'BMW Isetta 300 Export','Autoshow',45000,3.2,4,3.3,3.1,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1981,'BMW M1','Autoshow',585000,6.6,5.4,6.1,7.2,5.4,'B 652');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'BMW M2 CoupÃ©','Autoshow',69000,7.1,6.3,6.4,8.1,6.3,'A 737');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1991,'BMW M3','Autoshow',70000,6.4,5.4,6,7.4,5,'C 586');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'BMW M3','Autoshow',35000,7.1,5.9,6.3,8,5.5,'B 694');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2005,'BMW M3','HL: The Drift Run - Tier 8',33000,7,6.1,6.4,8,5.7,'B 700');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'BMW M3','Autoshow',48000,7.3,6.3,6.3,7.9,6.4,'A 745');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2002,'BMW M3-GTR','Hard-to-Find: Festival reward',120000,7.2,6.9,6.6,8.2,7,'A 765');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'BMW M3 GTS','Hard-to-Find: Festival reward',250000,7.4,7.6,6.6,8.3,8,'S1 814');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'BMW M4 Coupe','Autoshow',92000,7.7,6.9,6.5,8.2,7.5,'A 800');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'BMW M4 GTS','Autoshow',135000,7.4,8.1,6.7,8.4,8.8,'S1 841');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1988,'BMW M5','Autoshow',54000,6.5,5.3,6,7.7,5.3,'C 594');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1988,'BMW M5 F.E.','Wheelspin reward',304000,7.3,6.7,6.7,8.3,7.1,'A 800');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1995,'BMW M5','Autoshow',25000,7.3,5.5,6.1,7.8,5.4,'B 634');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2003,'BMW M5','Autoshow',30000,7.6,6,6.3,7.9,6,'A 719');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2009,'BMW M5','Autoshow',90000,7.6,6.5,6.5,8.2,6.6,'A 758');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'BMW M5','Autoshow',112000,7.9,6.6,6.5,8.2,6.7,'A 790');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'BMW M5','DLC: Fortune Island',105000,8,6.5,9.3,10,7.2,'S1 806');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'BMW M6 Coupe','Autoshow',120000,7.9,6.3,6.3,7.9,6.8,'A 779');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2013,'BMW M6 Coupe F.E.','Wheelspin reward',370000,9.1,7.7,7.4,9,8.2,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2011,'BMW X5 M','Autoshow',100000,7,5.8,7.4,9.1,5.5,'A 708');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'BMW X6 M','Autoshow',130000,7.1,6,7.5,9.4,5.8,'A 727');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2002,'BMW Z3 M Coupe','Autoshow',30000,6.8,6.1,6.4,8.1,6.1,'A 713');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'BMW Z4 M Coupe','Autoshow',82000,7,6.5,6.6,8.3,6,'A 710');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2019,'BMW Z4 Roadster','Hard-to-Find: Festival reward',35000,7.2,6.7,6.8,8.4,6.7,'A 722');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'BMW Z4 sDrive35is','Autoshow',58000,7.2,6.2,6.5,8.2,5.7,'A 727');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Bowler EXR S','Autoshow',200000,6.8,6.2,8.8,10,6,'A 760');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2018,'Bugatti Chiron','Autoshow',2400000,10,8.3,9.8,10,8.7,'S2 938');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'Bugatti Divo','Hard-to-Find: Festival reward',250000,9.3,9.2,9.9,10,9.5,'S2 958');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1992,'Bugatti EB110 Super Sport','Autoshow',1700000,8.5,7.1,9.2,9.9,7.4,'S1 829');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1926,'Bugatti Type 35 C','Autoshow',10000000,5,4.9,4.4,4.8,4.8,'D 374');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2011,'Bugatti Veyron Super Sport','Autoshow',2200000,9.9,8,9.9,10,8.4,'S2 922');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1970,'Buick GSX','Hard-to-Find: Festival reward',250000,6,4.8,5.1,6.5,4.4,'C 572');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1987,'Buick Regal GNX','Autoshow',130000,6.5,4.7,5.6,7.1,4.5,'C 567');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Cadillac ATS-V','Autoshow',65000,7.5,6.2,6.4,8.1,6.2,'A 737');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Cadillac CTS-V Sedan','Autoshow',80000,7.7,6.2,6.3,7.9,6.6,'A 785');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1959,'Cadillac Eldorado Biarritz Convertible','DLC: Car Pass',60000,5.9,4.4,5.2,6.6,4.3,'D 400');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2012,'Cadillac Escalade ESV','Hard-to-Find: Festival reward',250000,6,5.7,5,6,5.9,'C 564');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Cadillac XTS Limousine','Wheelspin reward',48500,6.1,5.7,4.6,5.1,5.4,'C 534');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2018,'Can-Am Maverick X RS Turbo R','DLC: Car Pass',25000,5,6.5,8.2,10,6.4,'B 692');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Caterham Superlight R500','Autoshow',82000,6.4,6.9,6.8,7.9,7.1,'S1 804');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2013,'Caterham Superlight R500 F.E.','Wheelspin reward',332000,6.4,7,6.7,8.4,7.1,'S1 804');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1955,'Chevrolet 150 Utility Sedan','Autoshow',35000,5.4,3.8,5,6.3,3.6,'D 286');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1957,'Chevrolet Bel Air','Autoshow',130000,5.7,4.3,4.7,5.1,4.3,'D 444');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'Chevrolet Camaro Super Sport Coupe','Autoshow',110000,5.9,4.9,5.3,6.7,4.6,'C 566');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Chevrolet Camaro Z28','Autoshow',53000,6,4.7,5.2,6.5,4.3,'C 547');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1979,'Chevrolet Camaro Z28','Wheelspin reward',35000,5.5,4.8,5.3,6.7,4.4,'D 460');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Chevrolet Camaro Z/28','Autoshow',86000,7.2,7.7,6.6,8.3,8.3,'S1 818');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Chevrolet Camaro ZL1','Autoshow',60000,7.8,8,7.3,8.7,8.4,'S1 848');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Chevrolet Camaro ZL1 Preorder Car','Pre-Order bonus / Forzathon Shop',60000,8.3,8.8,7.3,8.9,9.3,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Chevrolet Camaro ZL1 1LE','DLC: Car Pass',105000,7.5,8.4,7,8.6,8.8,'S1 849');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1967,'Chevrolet Chevelle Super Sport 396','Hard-to-Find: Festival reward',250000,6.5,4.6,5.2,6.6,4.4,'C 561');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Chevrolet Chevelle Super Sport 454','Autoshow',80000,5.6,4.6,5.1,6.4,4.3,'C 542');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1970,'Chevrolet Chevelle Super Sport Barrett-Jackson Edition','DLC: Barrett-Jackson Car Pack',105000,7.8,5.9,6.1,7.8,6.2,'A 757');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Chevrolet Colorado ZR2','Hard-to-Find: Festival reward',46000,6.1,5.7,5.7,7.3,5.6,'C 598');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1953,'Chevrolet Corvette','Autoshow',135000,4.7,4.4,4.2,4.3,4.2,'D 347');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1960,'Chevrolet Corvette','Autoshow',150000,6.2,4.6,5.2,6.6,4.4,'C 521');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1967,'Chevrolet Corvette Stingray 427','Autoshow',150000,6.3,5,5.6,6.7,4.8,'B 621');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2002,'Chevrolet Corvette Z06','Autoshow',35000,7.7,6.5,6,7.6,5.4,'A 748');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Chevrolet Corvette Z06','Autoshow',110000,7.9,8.2,7,8.6,8.9,'S1 871');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Chevrolet Corvette ZR-1','Autoshow',310000,5.8,5.1,5.6,6.7,4.7,'B 605');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1995,'Chevrolet Corvette ZR-1','Autoshow',45000,7.1,6.3,6.4,7.8,5.8,'A 741');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2009,'Chevrolet Corvette ZR1','Autoshow',125000,8.2,7.1,6.7,6.3,7.5,'S1 824');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'Chevrolet Corvette ZR1','DLC: Car Pass',225000,8.1,8.5,7.5,9,9.2,'S1 895');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Chevrolet El Camino Super Sport 454','Autoshow',65000,6.6,4.6,5,6.3,4.3,'C 556');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1996,'Chevrolet Impala Super Sport','Hard-to-Find: Festival reward',250000,5.9,4.8,5.4,6.6,4.6,'C 510');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1964,'Chevrolet Impala Super Sport 409','Autoshow',46000,6.3,4.3,5.1,6.4,4.2,'C 527');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1988,'Chevrolet Monte Carlo Super Sport','HL: LaRacer - Tier 10',25000,5.9,4.5,5,6.3,3.9,'D 415');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1966,'Chevrolet Nova Super Sport','Autoshow',70000,6.2,4.8,5.4,6.9,4.5,'C 582');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1969,'Chevrolet Nova Super Sport 396','Autoshow',47000,6.2,4.6,5.3,6.6,4.3,'C 552');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1969,'Chevrolet Nova Super Sport 396 F.E.','Wheelspin reward',297000,8.5,7.3,10,10,7.5,'S2 981');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Chevrolet Silverado 1500 DeBerti Design Drift Truck','DLC: Car Pass',300000,7.2,7.6,6.6,8.3,7.7,'S1 849');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1972,'Chrysler VH Valiant Charger R/T E49','Autoshow',60000,5.9,4.7,5.2,6.7,4.4,'C 557');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1970,'Datsun 510','Autoshow',25000,4.8,3.9,4.7,6.1,3.8,'D 209');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Dodge Challenger R/T','Autoshow',210000,6.2,4.7,5.2,6.5,4.4,'C 562');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Dodge Challenger SRT Demon','HL: The Stunt Driver - Tier 10',150000,8.2,7,6.3,8,7.4,'S1 823');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Dodge Challenger SRT Hellcat','Autoshow',75000,8.1,6.1,5.9,7.5,6.5,'A 776');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1969,'Dodge Charger Daytona Hemi','Autoshow',900000,5.9,5.2,5.4,6.9,4.8,'C 595');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'Dodge Charger R/T','Autoshow',103000,5.9,4.7,5.3,6.8,4.3,'C 558');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Dodge Charger SRT Hellcat','Autoshow',80000,8.2,6.1,6.1,7.7,6.5,'A 785');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1968,'Dodge Dart Hemi Super Stock','Autoshow',125000,5.4,4.9,5.5,7,4.6,'B 626');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Dodge Durango SRT','Autoshow',70000,6.9,5.9,7.3,9.2,5.5,'A 709');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Dodge SRT Viper GTS','Autoshow',95000,8,7.3,7,8.2,7.2,'S1 831');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Dodge Viper ACR','Autoshow',150000,6.9,9.8,7.6,8.7,10,'S1 893');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1999,'Dodge Viper GTS ACR','Autoshow',75000,7.4,5.9,6.6,8.1,5.9,'A 732');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'Dodge Viper SRT10 ACR','Autoshow',90000,7.5,9.2,7.1,8.3,9.6,'S1 866');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Donkervoort D8 GTO','Autoshow',175000,6.9,7.4,6.7,8.4,7.8,'S1 827');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2011,'DS Automobiles DS3 Racing','Hard-to-Find: Festival reward',38000,6.1,6,5.8,7.3,6,'B 624');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2012,'Eagle Speedster','Autoshow',550000,6.8,6.5,6.1,7.8,6.7,'A 740');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Exomotive Exocet Off-Road','DLC: Fortune Island',50000,5.4,7.7,6.8,8.5,7.4,'A 729');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1967,'Ferrari #24 Ferrari Spa 330 P4','Autoshow',10000000,7.6,6.8,7.3,8.9,6,'A 799');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1948,'Ferrari 166MM Barchetta','Autoshow',6500000,5.7,5.1,5.5,7.1,4.9,'C 554');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1957,'Ferrari 250 California','Autoshow',8000000,6.2,4.6,5.2,6,4.5,'C 540');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1962,'Ferrari 250 GT Berlinetta Lusso','Autoshow',2600000,6.3,4.7,5.6,7.2,4.6,'C 568');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1962,'Ferrari 250 GTO','Autoshow',10000000,7,5.6,5.3,6.2,4.7,'B 679');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1963,'Ferrari 250LM','Autoshow',10000000,7.1,6,5.1,5.9,5.6,'A 732');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1957,'Ferrari 250 Testa Rossa','Autoshow',10000000,6.9,5.6,6,7.7,4.7,'A 704');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1984,'Ferrari 288 GTO','Autoshow',3100000,7.8,6.2,6.8,8.4,6.1,'A 768');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2003,'Ferrari 360 Challenge Stradale','Autoshow',200000,7.5,7,7.1,8.7,7.4,'A 792');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1968,'Ferrari 365 GTB/4','Autoshow',600000,7.5,5.1,5.9,7.1,4.6,'B 641');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2007,'Ferrari 430 Scuderia','Autoshow',300000,8,7.4,7.2,8.8,7.9,'S1 834');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2009,'Ferrari 458 Italia','Autoshow',225000,8.1,7.3,7.3,8.9,7.9,'S1 846');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Ferrari 458 Speciale','Autoshow',340000,8.1,8.2,7.6,9.1,8.8,'S1 885');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Ferrari 488 GTB','Autoshow',290000,8.5,8.1,7.5,9.1,8.7,'S1 883');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'Ferrari 488 Pista','Hard-to-Find: Festival reward',250000,8,9,8,9.4,9.6,'S2 912');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1953,'Ferrari 500 Mondial','Autoshow',1000000,6.1,5.1,4.7,5,4.7,'C 544');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1970,'Ferrari 512 S','Hard-to-Find: Festival reward',250000,8,8,7.9,9,7.5,'S1 872');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1992,'Ferrari 512 TR','Autoshow',270000,7.9,6.3,6.6,7.7,5.8,'A 754');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2002,'Ferrari 575M Maranello','Autoshow',140000,7.9,6.2,6.6,8.3,6.1,'A 772');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Ferrari 599 GTO','Autoshow',690000,8.3,7.9,7.3,8.9,8.5,'S1 861');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2010,'Ferrari 599XX','Autoshow',1000000,7.8,9.4,7.9,9.3,9.9,'S2 937');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2012,'Ferrari 599XX Evolution','Hard-to-Find: Festival reward',250000,8.9,10,8.1,9.5,10,'S2 979');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2017,'Ferrari 812 Superfast','Star Card: Story',1400000,8.3,8.1,7.1,8.7,8.6,'S1 897');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Ferrari California T','Autoshow',240000,7.7,6.7,6.8,8.5,7.3,'S1 804');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1969,'Ferrari Dino 246 GT','Autoshow',425000,6,4.8,5,5.8,4.5,'C 512');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2002,'Ferrari Enzo Ferrari','Autoshow',2800000,8.4,8,7.4,8.9,8.4,'S1 874');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Ferrari GTC4Lusso','DLC: Car Pass',430000,8,7.3,8.2,9.4,7.9,'S1 840');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Ferrari F12berlinetta','Autoshow',380000,8.3,7.3,7.1,8.7,7.9,'S1 868');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Ferrari F12tdf','Autoshow',500000,8.8,8.3,7.3,8.9,9,'S2 901');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1987,'Ferrari F40','Autoshow',1200000,7.7,7,7.5,8.1,7,'S1 807');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1989,'Ferrari F40 Competizione','Autoshow',3000000,8.5,10,7,5.4,10,'S2 961');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1995,'Ferrari F50','Autoshow',2000000,7.8,7.1,7.2,8.5,7.4,'S1 815');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1996,'Ferrari F50 GT','Autoshow',1200000,8.4,10,8.4,9.5,10,'S2 992');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1994,'Ferrari F355 Berlinetta','Autoshow',190000,7.4,6.3,6.2,7.4,6.3,'A 737');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2011,'Ferrari FF','Autoshow',255000,8.1,6.6,7.5,8.8,7.2,'S1 815');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2005,'Ferrari FXX','DLC: Car Pass',2500000,8.3,10,8.7,9.9,10,'S2 961');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2014,'Ferrari FXX K','Autoshow',2700000,8.1,10,8.8,9.9,10,'S2 989');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2013,'Ferrari LaFerrari','Autoshow',1500000,9.5,9.8,8.2,9.5,10,'S2 966');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ferrari Portofino','HL: Horizon Promo - Tier 6',215000,8.2,7.3,7.2,8.8,7.9,'S1 834');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1980,'FIAT 124 Sport Spider','Autoshow',25000,4.9,4,4.2,6.5,4,'D 244');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'FIAT Dino 2.4 Coupe','Hard-to-Find: Festival reward',250000,5.7,4.7,5.4,6.9,4.5,'D 468');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1966,'Ford #2 GT40 Mk II Le Mans','Autoshow',10000000,7.8,6.6,6,7.2,6,'A 795');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Ford #11 Rockstar F-150 Trophy Truck','Autoshow',500000,6.4,6.6,6.6,8,6.2,'A 785');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Ford #14 Rahal Letterman Lanigan Racing GRC Fiesta','Autoshow',500000,5.8,7.7,10,10,8,'S1 880');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ford #25 RTR Mustang','HL: Drift Adventure - Tier 19',500000,6.6,7.9,6.7,8.4,8,'S1 871');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ford #88 RTR Mustang','Hard-to-Find: Festival reward',500000,6.6,7.9,6.7,8.4,8,'S1 871');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1959,'Ford Anglia 105E','Autoshow',20000,3.9,3.9,3.7,4.9,3.9,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1975,'Ford Bronco','Autoshow',38000,5.2,4.2,5.3,7,3.9,'D 379');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1975,'Ford Bronco Barrett-Jackson Edition','DLC: Barrett-Jackson Car Pack',105000,5.4,6.3,6.6,8.1,5.7,'B 630');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1973,'Ford Capri RS3100','Autoshow',55000,5.7,4.7,5.4,6.9,4.4,'D 478');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1973,'Ford Capri RS3100 F.E.','Star Card: Complete all challenges',305000,5.7,6.5,5.5,7.1,5.3,'B 613');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2010,'Fordown Victoria Police Interceptor','Wheelspin reward',25000,6,5.1,4.9,5.6,4.7,'C 521');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1932,"'Ford Custom ""Double Down""'",'DLC: Barrett-Jackson Car Pack',105000,8.6,8,10,10,8.2,'S2 927');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1940,'Ford De Luxe Coupe','Autoshow',44000,4.4,3.8,4.1,5.5,3.7,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1932,'Ford De Luxe Five-Window Coupe','Autoshow',35000,4.4,3.8,3.9,5.9,3.2,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1973,'Ford Escort RS1600','Autoshow',73000,5.2,5,5.4,6.7,4.8,'D 440');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1977,'Ford Escort RS1800','Autoshow',88000,5.2,4,5.1,6.5,3.7,'D 311');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1992,'Ford Escort RS Cosworth','Autoshow',66000,6,5.3,6,8,5.3,'C 566');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1986,'Ford Escort RS Turbo','Barn Find',25000,5.5,5.2,5.7,7.3,4.9,'C 506');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1956,'Ford F-100','Autoshow',36000,4.9,3.7,4.9,6.1,3.7,'D 221');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ford F-150 Prerunner DeBerti Design Truck','HL: The Eliminator - Tier 15',250000,6.5,6.3,7.4,9,6.3,'A 750');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2017,'Ford F-150 Raptor','Autoshow',63000,5.8,5.9,6.4,8.5,5.4,'B 627');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Ford F-150 SVT Raptor','Wheelspin reward',42000,6.1,5.5,5.8,7.2,4.9,'C 564');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Ford Falcon GT F 351','Autoshow',60000,7.5,6.1,6.2,7.8,6.4,'A 739');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1972,'Ford Falcon XA GT-HO','Autoshow',80000,7,4.9,5.5,6.9,4.6,'B 608');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1972,'Ford Falcon XA GT-HO F.E.','Wheelspin reward',330000,7,7.4,7.2,8.5,6.8,'S1 811');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2014,'Ford Fiesta ST','Autoshow',25000,6.1,6.1,5.8,7.4,5.7,'B 621');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1981,'Ford Fiesta XR2','Autoshow',25000,4.8,4.7,4.9,6.4,4.6,'D 324');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2003,'Ford Focus RS','Autoshow',30000,6,6.2,6,7.7,6.4,'B 649');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2009,'Ford Focus RS','Autoshow',25000,6.3,6.3,6,7.6,6.5,'B 696');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Ford Focus RS','Autoshow',59000,6.9,6.3,7.3,9.2,6.5,'A 718');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Ford Focus RS Preorder Car',' Forzathon Shop',59000,7.4,6.7,9.2,10,7.4,'A 800');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Ford FPV Limited Edition Pursuit Ute','Autoshow',50000,7,5.8,6.1,7.7,5.9,'A 710');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2005,'Ford GT','Autoshow',300000,8.1,7.1,6.4,7.3,7.4,'S1 810');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Ford GT','Autoshow',400000,8.6,8.4,7.5,9,8.9,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1964,'Ford GT40 Mk I','Barn Find',9000000,7.4,6.4,6.2,7.4,5.7,'A 772');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1966,'Ford Lotus Cortina','Autoshow',50000,5.1,4.6,5.3,6.7,4.6,'D 379');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Ford M-Sport Fiesta RS','Autoshow',500000,5.9,7.9,9.9,10,8.2,'S1 819');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1968,'Ford Mustang 2+2 Fastback','DLC: Car Pass',50000,6.4,4.5,5.1,6.5,4.2,'C 505');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1969,'Ford Mustang Boss 302','HL: Drift Club - Tier 10',230000,6.3,5,5,5.8,4.6,'C 564');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Ford Mustang GT','Autoshow',40000,7.5,6.5,6.4,8.1,6.6,'A 778');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1965,'Ford Mustang GT Coupe','Autoshow',46000,6,4.4,5.1,6.4,4.3,'C 507');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ford Mustang GT DeBerti Design','DLC: Car Pass',500000,8.2,7.1,7.2,8.8,7.3,'S1 835');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1971,'Ford Mustang Mach 1','Autoshow',45000,5.7,4.8,5.1,6.4,4.4,'C 561');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Ford Mustang RTR Spec 5','Hard-to-Find: Festival reward',500000,8.2,7.1,7.2,8.8,7.3,'S1 835');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2019,'Ford Ranger Raptor','Autoshow',58000,5.5,5.8,4.6,7.3,5.6,'D 498');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Ford Ranger T6 Rally Raid','Autoshow',500000,5.4,5.8,7,10,5.8,'A 703');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1932,"'Ford Roadster ""Hula Girl""'",'DLC: Barrett-Jackson Car Pack',105000,5.2,5.7,6.1,7.8,5.1,'C 590');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1985,'Ford RS200','HL: Dirt Racing - Tier 4',260000,6.2,7.4,8.2,8,7.2,'S1 839');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Ford Shelby GT350R','Autoshow',75000,7.7,8.1,7.2,8.8,8.5,'S1 840');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Ford Shelby GT500','Autoshow',115000,7.8,6.4,6.1,7.7,6.4,'A 774');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1987,'Ford Sierra Cosworth RS500','Autoshow',66000,6.4,5.7,6.1,7.7,5.2,'B 608');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1946,'Ford Super Deluxe Station Wagon','Autoshow',75000,4.6,3.7,3.7,5.4,3.6,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1994,'Ford Supervan 3','Hard-to-Find: Festival reward',500000,5.8,9.4,8.2,9.6,10,'S1 828');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1993,'Ford SVT Cobra R','Wheelspin reward',28000,6.1,4.8,5.5,7,4.9,'C 533');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2000,'Ford SVT Cobra R','Autoshow',55000,7.3,5.7,5.8,7.4,5.6,'B 682');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1965,'Ford Transit','DLC: Car Pass',25000,3.8,4.1,3.4,3,4.4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Ford Transit SuperSportVan','Autoshow',50000,5.4,5.1,4.6,7.1,5.1,'D 416');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2011,'Ford Transit SuperSportVan F.E.','DLC: VIP Membership',50000,5.4,5.1,4.6,7.1,5.1,'D 416');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1973,'Ford XB Falcon GT','Wheelspin reward',60000,6,4.7,5.1,6.4,4.5,'C 529');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1989,'Formula Drift #98 BMW 325i','DLC: Formula Drift Car Pack',300000,7.4,7.2,6.6,8.2,7.2,'S1 837');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2006,'Formula Drift #43 Dodge Viper SRT10','DLC: Formula Drift Car Pack',300000,7.7,7.8,6.6,8.2,7.9,'S1 859');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Formula Drift #13 Ford Mustang','DLC: Formula Drift Car Pack',300000,6.6,7.6,6.6,8.3,7.7,'S1 852');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Formula Drift #530 HSV Maloo Gen-F','DLC: Formula Drift Car Pack',300000,7.9,7.3,6.2,7.9,7.4,'S1 836');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2007,'Formula Drift #117 599 GTB Fiorano','Hard-to-Find: Festival reward',500000,7.3,8.2,7.2,8.8,8.3,'S1 896');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1995,'Formula Drift #118 Nissan 240SX','DLC: Formula Drift Car Pack',300000,6.5,7.6,6.9,8.5,7.6,'S1 860');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1996,'Formula Drift #232 Nissan 240SX','DLC: Formula Drift Car Pack',300000,7.5,7.6,6.5,8.2,7.6,'S1 859');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Formula Drift #777 Chevrolet Corvette','Hard-to-Find: Festival reward',500000,7,7.8,6.6,8.3,7.8,'S1 885');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1997,'Formula Drift #777 Nissan 240SX','DLC: Formula Drift Car Pack',300000,7.3,7.5,6.8,8.4,7.5,'S1 861');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Funco Motorsports F9','DLC: Fortune Island',500000,6,6.7,8.7,9.9,6.7,'S1 860');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1983,'GMC Vandura G-1500','Autoshow',25000,4.7,3.9,4.3,5.4,3.8,'D 151');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1985,'HDT VK Commodore Group A','Autoshow',28000,5.9,4.8,5.5,6.6,4.6,'C 545');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2012,'Hennessey Venom GT','Autoshow',1200000,10,8.3,7.6,9.1,8.7,'S2 930');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1966,'Hillman Imp','DLC: Car Pass',25000,4.3,4,3.7,5.6,3.8,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1973,'Holden HQ Monaro GTS 350','Autoshow',75000,5.7,4.7,5.3,6.7,4.4,'C 524');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1974,'Holden Sandman HQ Panel Van','Autoshow',55000,5.7,4.7,5.4,6.9,4.5,'D 500');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1977,'Holden Torana A9X','Autoshow',130000,5.8,4.7,5.1,6.5,4.5,'C 507');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Honda Civic Coupe GRC','DLC: Car Pass',155000,5.8,7.8,10,10,8,'S1 878');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1984,'Honda CivicX Mugen','Hard-to-Find: Festival reward',40000,5.7,5,4.9,5.4,4.7,'D 492');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1974,'Honda Civic RS','DLC: Car Pass',25000,5,4.7,4.3,6.7,4.3,'D 320');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'Honda Civic Type R','Autoshow',25000,6.2,5.3,5.5,6.8,5.2,'C 551');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2004,'Honda Civic Type-R','Wheelspin reward',25000,6.2,5.8,5.7,7.2,5.5,'B 610');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2007,'Honda Civic Type-R','Autoshow',20000,6.1,6.2,5.7,6.9,5.3,'C 576');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2015,'Honda Civic Type R','Autoshow',38000,7,6.4,6.1,7.7,6.6,'A 714');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Honda Civic Type R','Hard-to-Find: Festival reward',59000,7.4,6.7,6,7.7,6.8,'A 745');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1991,'Honda-X SiR','Autoshow',20000,6,5.1,5,6,4.7,'C 504');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1992,'Honda NSX-R','Autoshow',90000,6.9,6.3,6.6,7.7,6.4,'A 707');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2005,'Honda NSX-R','Wheelspin reward',150000,7,6.4,6.6,7.8,5.9,'A 714');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2005,'Honda NSX-R GT','DLC: Car Pass',500000,7,6.9,6.9,8.3,6.8,'A 744');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1994,'Honda Prelude Si','Hard-to-Find: Festival reward',250000,5.9,5.3,5.5,7.3,4.8,'D 500');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Honda Ridgeline Baja Trophy Truck','Autoshow',500000,6,6.4,6.8,8.5,6.2,'A 751');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2003,'Honda S2000','DLC: Car Pass',25000,6.6,5.4,5.9,7.4,4.9,'B 618');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2009,'Honda S2000','Autoshow',25000,6.4,6.2,6.2,7.5,5.3,'B 647');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1955,'Hoonigan Chevrolet Bel Air','Autoshow',76000,6.5,4.3,5.8,6.9,4.5,'C 571');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1972,"'Hoonigan Chevrolet ""Napalm Nova""'",'Wheelspin reward',50000,7.3,6.3,6.4,8.1,6.7,'A 765');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1978,'Hoonigan Ford Escort RS1800','Autoshow',300000,6.7,7.7,6.6,8.3,8.2,'S1 828');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,"'Hoonigan Ford ""Hoonicorn"" Mustang'",'Autoshow',500000,9.3,8.2,10,10,8.5,'S2 985');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1986,'Hoonigan Ford RS200 Evolution','Hard-to-Find: Festival reward',500000,8,8.2,10,10,7.9,'S2 932');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Hoonigan Gymkhana 8 Ford Fiesta ST RX43','DLC: Fortune Island',500000,5.9,7.9,10,10,8.5,'S1 886');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Hoonigan Gymkhana 9 Ford Focus RS RX','Autoshow',500000,5.9,7.9,10,10,8.5,'S1 886');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1991,'Hoonigan Gymkhana 10 Ford Escort Cosworth Group A','DLC: Car Pass',500000,7.9,7.4,10,10,7.5,'S1 880');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1977,'Hoonigan Gymkhana 10 Ford F-150 ''Hoonitruck''','DLC: Car Pass',500000,6.8,8.2,9.2,10,8.7,'S2 916');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Hoonigan Gymkhana 10 Ford Fiesta ST','Hard-to-Find: Festival reward',500000,5.7,8.2,9,10,8.4,'S1 828');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Hoonigan Gymkhana 10 Ford Focus RS RX','HL: Skill Streak - Tier 10',500000,5.9,7.9,10,10,8.5,'S1 886');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,'Hoonigan Gymkhana 10 Ford Hoonicorn Mustang','Hard-to-Find: Festival reward',500000,9,8.2,10,10,8.5,'S2 985');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1992,'Hoonigan Mazda RX-7 Twerkstallion','Autoshow',50000,8.6,7.3,6.3,8,7.3,'S1 838');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1991,'Hoonigan Rauh-Welt Begriff Porsche 911 Turbo','HL: Street Scene - Tier 17',160000,7.3,8.6,8.2,9.5,8.5,'S1 850');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2011,'Hot Wheels Bone Shaker','Hard-to-Find: Festival reward',150000,6.7,7,6.9,8.5,7.4,'A 795');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2005,'Hot Wheels Ford Mustang','Hard-to-Find: Festival reward',300000,7.1,9.2,7.3,8.8,9.7,'S1 841');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Hot Wheels Rip Rod','Star Card: PR Stunt',300000,6.2,6.4,7.3,8.8,6.3,'A 747');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1969,'Hot Wheels Twin Mill','Hard-to-Find: Festival reward',110000,8.8,6.6,6.2,7.9,7.1,'S1 821');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'HSV Gen-F GTS','Autoshow',75000,7.6,6.1,6.2,7.8,6.4,'A 747');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'HSV Limited Edition Gen-F GTS Maloo','Autoshow',62000,7.1,6.4,6.2,7.8,6.9,'A 764');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1952,'Hudson Hornet','Hard-to-Find: Festival reward',66000,5,4.2,4.8,6.5,4.3,'D 305');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2006,'Hummer H1 Alpha','Wheelspin reward',112000,5.2,5.4,4,6.2,4.9,'D 391');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2006,'Hummer H1 Alpha Open Top','Hard-to-Find: Festival reward',250000,5.1,5.4,4.1,6.5,5,'D 382');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2019,'Hyundai Veloster N','Autoshow',30000,6.7,5.8,6,7.6,5.8,'B 657');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Infiniti Q50 Eau Rouge','Autoshow',100000,8.1,6.4,9.2,10,6.8,'A 783');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Infiniti Q60 Concept','Autoshow',50000,7.4,6.3,6.1,7.7,6.6,'A 757');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1970,'International Scout 800A','Autoshow',40000,5.1,4.1,4.6,7.6,3.8,'D 334');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Italdesign Zerouno','Hard-to-Find: Festival reward',250000,8,8.7,10,10,9.3,'S1 893');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1953,'Jaguar C-Type','DLC: Car Pass',5000000,6.4,4.1,5.2,6.6,4,'D 495');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1956,'Jaguar D-Type','Autoshow',10000000,6.4,4.2,5.1,6.4,3.6,'C 513');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1961,'Jaguar E-type S1','Barn Find',150000,6,5,5.7,7,4.7,'C 539');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2017,'Jaguar F-Pace S','Autoshow',55000,6.6,5.9,7,8.7,6,'B 698');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Jaguar F-Type Project 7','Autoshow',190000,7.5,7,6.4,8,7.4,'S1 805');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Jaguar F-Type R CoupÃ©','Autoshow',110000,7.9,6.5,6.4,8.1,6.9,'A 795');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1964,'Jaguar Lightweight E-Type','Autoshow',10000000,6.9,5.5,6,7.7,5.5,'A 707');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1959,'Jaguar Mk II 3.8','Autoshow',80000,5.5,4.5,5.1,6.5,4.8,'D 414');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2015,'Jaguar XE-S','Autoshow',57000,7.3,5.5,6,7.7,5.3,'B 660');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1993,'Jaguar XJ220','Barn Find',350000,8.3,6.8,6.8,7.6,7.1,'S1 811');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Jaguar XFR-S','Autoshow',110000,8,6.2,6.3,7.9,6.5,'A 755');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1990,'Jaguar XJ-S','Autoshow',25000,6.8,4.7,4.8,5.7,4.8,'C 557');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1954,'Jaguar XK120 SE','Autoshow',120000,5.8,4.5,5.7,7.1,4.4,'D 469');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Jaguar XKR-S','Autoshow',100000,7.9,6.5,6.2,7.8,6.7,'A 782');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Jaguar XKR-S GT','HL: Road Racing - Tier 16',190000,7.7,6.9,6.4,8.1,7.5,'A 798');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1974,'James Bond Edition AMC Hornet X Hatchback','DLC: Best of Bond Car Pack',35000,5.7,4.3,5.1,6.4,4.2,'D 414');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1964,'James Bond Edition Aston Martin DB5','DLC: Best of Bond Car Pack',650000,6.3,5,5.7,7.2,4.7,'B 618');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2015,'James Bond Edition Aston Martin DB10','DLC: Best of Bond Car Pack',220000,7.7,7.4,6.9,8.5,8,'S1 814');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'James Bond Edition Aston Martin DBS','DLC: Best of Bond Car Pack',650000,7,5,5.8,7.4,5,'B 612');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2008,'James Bond Edition Aston Martin DBS','DLC: Best of Bond Car Pack',325000,7.7,6.9,6.5,8.2,7.4,'A 779');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1986,'James Bond Edition Aston Martin V8','DLC: Best of Bond Car Pack',200000,6.9,5.3,5.7,6.8,4.9,'B 620');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1999,'James Bond Edition BMW Z8','DLC: Best of Bond Car Pack',150000,6.9,6.3,6.3,8,5.7,'A 720');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1981,'James Bond Edition CitroÃ«n 2CV6','DLC: Best of Bond Car Pack',80000,4.1,3.9,4.1,4.8,3.8,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2010,'James Bond Edition Jaguar C-X75','DLC: Best of Bond Car Pack',1500000,8.3,7.9,9.8,10,8.5,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1977,'James Bond Edition Lotus Esprit S1','DLC: Best of Bond Car Pack',550000,5.7,5.6,5.6,6.8,5.1,'C 541');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1976,'Jeep CJ5 Renegade','Autoshow',60000,4.8,4.7,6,8.9,4.6,'D 417');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2014,'Jeep Grand Cherokee SRT','Wheelspin reward',80000,6.7,6,7.5,9.3,6.1,'A 711');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Jeep Grand Cherokee Trackhawk','HL:oss Country - Tier 8',73000,7.4,6.2,9.3,10,6.7,'A 780');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Jeep Trailcat','HL:oss Country - Tier 4',75000,6.8,6.5,7,8.1,5.6,'A 790');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'Jeep Wrangler Unlimited DeBerti Design','Hard-to-Find: Festival reward',250000,5.6,6.6,7.7,8.7,6.5,'A 796');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2012,'Jeep Wrangler Rubicon','Autoshow',50000,5.6,4.8,5.7,7.3,4.3,'D 488');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2018,'Kia Stinger','Autoshow',46000,7.3,6,6.2,7.8,5.9,'A 715');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2011,'Koenigsegg Agera','Autoshow',1500000,9.6,8.5,7.3,8.9,8.9,'S2 920');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2017,'Koenigsegg Agera RS','DLC: Car Pass',2000000,10,9.5,7.5,9,10,'S2 996');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2002,'Koenigsegg CC8S','DLC: Fortune Island Treasure Chest #5',320000,9,8.4,7.3,8.3,8.5,'S1 883');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2008,'Koenigsegg CCGT','Hard-to-Find: Festival reward',250000,7.8,10,7.9,9.3,10,'S2 986');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2006,'Koenigsegg CCX','Hard-to-Find: Festival reward',250000,9,7.9,7.3,8.8,8.3,'S1 881');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2015,'Koenigsegg One:1','Autoshow',2850000,10,9.8,7.5,9,10,'S2 993');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Koenigsegg Regera','Autoshow',1900000,9.2,9.1,7.3,8.9,9.7,'S2 972');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'KTM X-Bow GT4','Hard-to-Find: Festival reward',400000,6.3,10,6.7,7.9,10,'S1 861');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'KTM X-Bow R','Autoshow',105000,6,9.1,7.5,9.1,9.8,'S1 819');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Lamborghini Aventador J','DLC: Fortune Island Treasure Chest #10',2700000,8.3,7.9,9.4,10,8.3,'S1 871');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Lamborghini Aventador LP700-4','Autoshow',310000,8.7,7.8,9.8,10,8.3,'S1 882');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2012,'Lamborghini Aventador LP700-4 F.E.','Wheelspin reward',560000,9,8.5,10,10,8.4,'S2 997');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Lamborghini Aventador LP750-4 SV','Wheelspin reward',480000,8.7,8.7,10,10,9.1,'S2 906');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Lamborghini Centenario LP 770-4','Autoshow',2300000,8.6,9.4,10,10,9.8,'S2 918');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1988,'Lamborghini Countach LP5000 QV','Autoshow',220000,7.4,6.6,6.4,7.5,6,'A 759');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1997,'Lamborghini Diablo SV','Autoshow',174000,8.1,6.6,6.8,8,6.5,'A 787');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1999,'Lamborghini Diablo GTR','Hard-to-Find: Festival reward',250000,7.8,9.9,8.2,9.1,10,'S2 915');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Lamborghini Gallardo LP 570-4 Spyder Performante','DLC: Car Pass',280000,7.5,7,7.9,8.1,7.6,'S1 814');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2011,'Lamborghini Gallardo LP 570-4 Superleggera','Autoshow',180000,7.9,7.2,8.4,9.4,7.5,'S1 833');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Lamborghini HuracÃ¡n LP 610-4','HL: Road Racing - Tier 4',240000,8.2,7.8,9.2,10,8.4,'S1 866');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2018,'Lamborghini HuracÃ¡n Performante','Hard-to-Find: Festival reward',275000,7.8,6.5,10,10,9.1,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1977,'Lamborghini Jarama S','DLC: Car Pass',150000,6.3,4.7,5.5,6.6,4.9,'C 559');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1986,'Lamborghini LM 002','Autoshow',180000,6.1,5,4.7,5.3,4.5,'C 553');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1967,'Lamborghini Miura P400','Autoshow',1000000,6.6,5.2,5.6,6.6,4.8,'B 619');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Lamborghini MurciÃ©lago LP 670-4 SV','Autoshow',500000,8.2,7.4,6.7,8,7.9,'S1 840');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2008,'Lamborghini ReventÃ³n','Autoshow',1375000,8.2,7.4,6.7,8,7.9,'S1 841');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2008,'Lamborghini ReventÃ³n F.E.','Skill Tree: Lamborghini Miura P400',1625000,8.2,7.7,6.7,8,8.2,'S1 847');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2011,'Lamborghini Sesto Elemento','Autoshow',2500000,8.1,10,10,10,10,'S2 948');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'Lamborghini Urus','DLC: Fortune Island Treasure Chest #2',150000,7.6,6.7,7.6,9.3,7.4,'A 795');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Lamborghini Urus Concept','Autoshow',230000,7.4,6.5,7,8.7,7.1,'A 774');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2013,'Lamborghini Veneno','Autoshow',4500000,8.5,10,10,10,10,'S2 943');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1982,'Lancia 037 Stradale','Autoshow',95000,6,5.5,6.1,7.3,5.5,'C 590');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1992,'Lancia Delta HF Integrale Evo','Wheelspin reward',60000,5.7,4.7,6.2,8,5,'C 532');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1986,'Lancia Delta S4','Autoshow',146000,5.8,5.4,7.1,8.7,5.6,'B 638');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1968,'Lancia Fulvia CoupÃ© Rallye 1.6 HF','Autoshow',60000,5.5,4.7,5.5,7,4.7,'D 490');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1974,'Lancia Stratos HF Stradale','Autoshow',550000,6.1,4.8,6.1,7.8,4.6,'C 544');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'Land Rover Defender 90','Autoshow',30000,4.8,4.8,4.6,5.5,4.5,'D 357');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1973,'Land Rover Range Rover','Barn Find',50000,4.5,4.6,4.3,6.7,4.4,'D 235');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Land Rover Range Rover Sport SVR','Autoshow',133000,7.1,6.2,7.5,9.2,6.4,'A 752');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1972,'Land Rover Series III','Autoshow',20000,3.9,4,3.7,4.7,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1972,'Land Rover Series III F.E.','Wheelspin reward',270000,6.6,6.3,7.6,8.8,5.6,'S1 802');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'LEGO Speed Champions Bugatti Chiron','DLC: LEGO Speed Champions',2400000,10,8,9.4,10,9,'S2 937');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1987,'LEGO Speed Champions Ferrari F40 Competizione','DLC: LEGO Speed Champions',3000000,8,10,8.7,7.1,10,'S2 973');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'LEGO Speed Champions McLaren Senna','DLC: LEGO Speed Champions',1000000,8.7,10,9.3,10,10,'S2 978');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1967,'LEGO Speed Champions Mini Cooper S Rally','DLC: LEGO Speed Champions',500000,6.4,8.1,8.8,10,8.3,'S1 831');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1974,'LEGO Speed Champions Porsche 911 Turbo 3.0','DLC: LEGO Speed Champions (Barn Find)',500000,7.6,9.4,8.5,9.8,10,'S1 898');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Lexus LFA','Hard-to-Find: Festival reward',500000,7.8,7.1,6.9,8.5,7.8,'S1 826');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Local Motors Rally Fighter','Autoshow',100000,6.7,6.4,6.1,7.3,5.9,'A 760');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1969,'Lola #6 Penske Sunoco T70 MkIIIB','Autoshow',850000,7.4,6.8,7.9,9.4,6.6,'S1 828');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2009,'Lotus 2-Eleven','Wheelspin reward',130000,6.2,9.3,7.4,8.9,9.9,'S1 813');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Lotus 3-Eleven','Autoshow',150000,6.8,9.3,8,9.4,9.9,'S1 870');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2000,'Lotus 340R','Autoshow',40000,5.6,7.6,7.1,8.5,7.8,'A 706');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1971,'Lotus Elan Sprint','Autoshow',57000,5.5,5,5.3,6.3,4.7,'D 456');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1956,'Lotus Eleven','Autoshow',140000,5.7,5.7,5.3,6.3,5.2,'C 553');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2005,'Lotus Elise 111S','Wheelspin reward',45000,5.7,7,6.3,7.8,7,'B 650');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1999,'Lotus Elise Series 1 Sport 190','Hard-to-Find: Festival reward',81000,6.1,6.9,7.2,8.6,6.8,'A 728');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1997,'Lotus Elise GT1','Barn Find',1800000,6.8,8.6,7.2,8.4,9,'S1 815');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2002,'Lotus Esprit V8','Autoshow',42000,7.3,6.6,7,8.6,6.5,'A 756');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Lotus Evora S','Autoshow',43000,7.1,6.6,7.2,8.8,6.6,'A 748');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'Lotus Exige S','Autoshow',85000,7,7.1,7.4,8.9,7.4,'A 772');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1939,'Maserati 8CTF','Autoshow',10000000,7.3,5.2,5.4,6.9,4.8,'B 648');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1957,'Maserati 300 S','Autoshow',6000000,6.2,5.3,5.8,7,4.7,'B 668');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1953,'Maserati A6GCS/53 Pininfarina Berlinetta','Autoshow',2000000,5.5,4.8,4.7,5.1,4.6,'D 486');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Maserati Ghibli S Q4','Hard-to-Find: Festival reward',250000,7.3,6.1,7.2,9,6.1,'A 737');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2010,'Maserati Gran Turismo S','Autoshow',156000,7.4,6.3,6.6,8.3,6.3,'A 727');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2017,'Maserati Levante S','Hard-to-Find: Festival reward',85000,7.2,5.9,6.7,8,6.2,'A 723');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2004,'Maserati MC12','Autoshow',1000000,8.4,8,7.5,9.1,8.3,'S1 861');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2004,'Maserati MC12 F.E.','Skill Tree: Maserati 300 S',1250000,8.4,10,8.8,9.9,10,'S2 945');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2008,'Maserati MC12 Versione Corsa','Hard-to-Find: Festival reward',2500000,8.1,10,8.9,10,10,'S2 993');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1961,'Maserati Tipo 61 Birdcage','Autoshow',2400000,7,5.9,6.3,8,5.7,'A 747');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2005,'Mazda Mazdaspeed MX-5','Autoshow',25000,5.9,6.1,5.2,7.8,5.7,'B 605');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2013,'Mazda MX-5','Autoshow',26000,5.7,5.5,5.7,7.4,5,'C 525');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Mazda MX-5','Autoshow',35000,6.2,6.2,6.3,7.9,5.7,'B 625');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1994,'Mazda MX-5 Miata','Autoshow',25000,5.5,4.9,5.2,6.4,4.3,'D 428');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'Mazda RX-7','Autoshow',35000,7.2,6,6.3,8,5.1,'B 681');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2002,'Mazda RX-7 Spirit R Type-A','DLC: Car Pass',30000,7.1,6.2,6.3,8,5.7,'A 711');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Mazda RX-8 R3','Autoshow',27000,6.5,6,6.1,7.7,5.6,'B 638');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1990,'Mazda Savanna RX-7','Autoshow',25000,6.5,5.3,6,7.7,5.3,'C 561');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2011,'McLaren 12C CoupÃ©','Hard-to-Find: Festival reward',250000,8.1,7.5,7.3,8.9,7.8,'S1 854');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'McLaren 570S CoupÃ©','Autoshow',224000,7.8,7.5,7.3,8.9,8,'S1 848');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'McLaren 600LT CoupÃ©','Hard-to-Find: Festival reward',250000,7.8,8.5,7.7,9.2,9,'S1 890');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'McLaren 650S CoupÃ©','Autoshow',420000,7.8,7.9,7.5,9.1,8.6,'S1 877');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'McLaren 650S Spider','DLC: Car Pass',420000,7.8,7.9,7.5,9.1,8.6,'S1 873');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'McLaren 720S Coupe','Autoshow',340000,8.6,8.9,7.9,9.4,9.4,'S2 929');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'McLaren 720S Coupe Preorder Car','Pre-Order bonus',340000,9.2,10,8.6,9.8,10,'S2 998');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'McLaren 720S Spider','Hard-to-Find: Festival reward',250000,7.9,8.7,7.9,9.3,9.4,'S2 914');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1993,'McLaren F1','Autoshow',2000000,9,6.9,7.3,8.5,7.2,'S1 826');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1997,'McLaren F1 GT','Autoshow',5200000,8.7,8.3,7.6,8.9,8.6,'S1 888');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2013,'McLaren P1','Autoshow',1350000,9.3,9.3,7.9,9.3,9.7,'S2 962');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2013,'McLaren P1 ''Owen''s Edition''','Unreleased (Exclusive Gift)',1200000,9.3,9.9,8.4,9.6,10,'S2 957');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2018,'McLaren Senna','Autoshow',1000000,8.4,10,8.7,9.9,10,'S2 977');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'McLaren Speedtail','Hard-to-Find: Festival reward',2250000,9.7,8.5,7.9,9.3,8.7,'S2 940');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2016,'Mercedes-AMG C 63 S CoupÃ©','Autoshow',90000,7.5,6.6,6.4,8.1,7.2,'A 777');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Mercedes-AMG E 63 S','Hard-to-Find: Festival reward',250000,8,6.5,9.3,10,7,'S1 805');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Mercedes-AMG GT 4-Door CoupÃ©','Hard-to-Find: Festival reward',105000,8.3,6.2,9.1,10,6.5,'A 797');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Mercedes-AMG GT R','Autoshow',295000,7.6,7.9,7.3,8.9,8.6,'S1 858');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Mercedes-AMG GT R Preorder Car','Pre-Order bonus / Gifted',295000,7.9,8.5,7.8,9.3,9.1,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Mercedes-AMG GT S','Autoshow',157000,7.6,7.3,7.1,8.7,7.9,'S1 820');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Mercedes-Benz #24 Tankpool24 Racing Truck','Autoshow',500000,6,6,6.9,8.6,6.8,'B 682');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1990,'Mercedes-Benz 190E 2.5-16 Evolution II','Autoshow',150000,6.6,5.3,5.7,7.2,5.4,'C 579');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1967,'Mercedes-Benz 280 SL','Hard-to-Find: Festival reward',150000,5.6,4.6,4.8,7,4.8,'D 448');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1954,'Mercedes-Benz 300 SL CoupÃ©','Autoshow',1200000,6,4.5,5.4,6.4,4.4,'D 476');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1955,'Mercedes-Benz 300 SLR','Autoshow',8000000,7.1,5.8,6.1,7.1,4.9,'A 708');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Mercedes-Benz A 45 AMG','Autoshow',65000,7.3,6.1,8,9.8,6.4,'A 722');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'Mercedes-Benz AMG CLK GTR','Autoshow',2000000,7.7,7.8,7.2,8.6,8.1,'S1 848');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'Mercedes-Benz C 63 AMG CoupÃ© Black Series','Autoshow',143000,8.1,6.6,6.4,8,7,'A 792');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,"'Mercedes-Benz E 350 D 4MATIC Terrain ""Project E-AT""'",'HL: Top Gear - Tier 4',250000,5.7,5.6,5.9,9,5.3,'C 578');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Mercedes-Benz E 63 AMG','Wheelspin reward',105000,8.1,6.2,8.4,9.8,6.5,'A 777');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2013,'Mercedes-Benz G 65 AMG','Autoshow',261000,6.6,5.6,8,10,5.6,'A 712');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Mercedes-Benz G 63 AMG 6x6','HL: Top Gear - Tier 7',250000,6.4,6.6,5.7,8.9,6,'B 674');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2009,'Mercedes-Benz SL 65 AMG Black Series','Autoshow',210000,8.2,7,6.7,8.3,7.3,'S1 820');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2009,'Mercedes-Benz SL 65 AMG Black Series F.E.','Skill Tree: Mercedes-Benz 300 SL CoupÃ©',460000,8.2,7,6.7,8.3,7.3,'S1 820');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'Mercedes-Benz SLK 55 AMG','Autoshow',78000,7.7,6.5,6.6,8.2,6.8,'A 766');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2011,'Mercedes-Benz SLS AMG','Autoshow',200000,8.1,6.9,6.9,8.5,7.4,'S1 822');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1929,'Mercedes-Benz Super Sport Kurz Barker Roadster','DLC: Car Pass',5000000,5.1,3.8,4.8,6,3.7,'D 229');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2014,'Mercedes-Benz Unimog U5023','Autoshow',100000,3.8,6.4,3.4,3.5,4.2,'D 163');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1939,'Mercedes-Benz W154','Autoshow',10000000,8.3,5.1,5.6,7.2,4.7,'B 676');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2018,'Mercedes-Benz X-Class','Hard-to-Find: Festival reward',65000,5.2,5.5,4.4,6.7,5.2,'D 417');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Mercury Cougar Eliminator','HL: The Eliminator - Tier 24',250000,5.4,4.7,5.1,6.4,4.3,'C 548');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1949,'Mercury Coupe','Autoshow',45000,4.6,3.9,4.4,6.3,3.7,'D 158');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1971,'Meyers Manx','Autoshow',35000,4.3,4.8,4.8,6,4.7,'D 218');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1986,'MG Metro 6R4','Autoshow',125000,5.5,8.6,9.9,10,8.8,'S1 852');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1958,'MG MGA Twin-Cam','Autoshow',40000,4.9,3.9,4.8,6.3,3.7,'D 222');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1965,'MG MGB GT','Barn Find',30000,5,4.5,4.7,6.6,4.5,'D 316');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1938,'MG TA Midget','DLC: Car Pass',50000,3.9,3.9,3.6,5,3.9,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,'MINI Cooper S','Barn Find',30000,4.7,4,4.5,6.2,3.9,'D 205');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2009,'MINI John Cooper Works','Autoshow',25000,6.2,6.2,5.8,7.4,6.5,'B 639');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2018,'MINI John Cooper Works Convertible','Hard-to-Find: Festival reward',250000,6.2,5.9,5.8,7.3,6.1,'B 639');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2018,'MINI John Cooper Works Countryman','Hard-to-Find: Festival reward',250000,5.9,5.6,5.6,8.1,5.3,'C 580');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'MINI John Cooper Works GP','Wheelspin reward',38000,6.2,5.8,5.8,7.4,5.7,'B 642');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2013,'MINI X-Raid All4 Racing Countryman','Autoshow',500000,4.4,5.8,6.8,9.9,5.9,'B 682');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'MINI X-Raid John Cooper Works Buggy','Hard-to-Find: Festival reward',500000,5.4,6.4,6.5,9.1,6.3,'B 674');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1995,'Mitsubishi Eclipse GSX','DLC: Mitsubishi Motors Car Pack',25000,6.6,5.2,5.7,7.8,4.7,'C 543');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1992,'Mitsubishi Galant VR-4','DLC: Mitsubishi Motors Car Pack',25000,6.2,4.8,6.3,8.2,4.9,'C 532');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'Mitsubishi GTO','DLC: Mitsubishi Motors Car Pack',20000,6.8,5.4,6.2,8.1,5.3,'B 602');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1999,'Mitsubishi Lancer Evolution VI GSR','DLC: Mitsubishi Motors Car Pack',28000,6.3,5.9,7.1,9.1,5.6,'B 675');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2004,'Mitsubishi Lancer Evolution VIII MR','DLC: Mitsubishi Motors Car Pack',31000,6.9,5.9,7.2,9.1,5.5,'B 686');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2006,'Mitsubishi Lancer Evolution IX MR','DLC: Mitsubishi Motors Car Pack',27000,6.7,5.9,6.4,8.3,5.5,'B 649');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'Mitsubishi Lancer Evolution X GSR','DLC: Mitsubishi Motors Car Pack',43000,6.4,6,6.7,8.9,6,'B 678');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Morgan 3 Wheeler','Autoshow',50000,5.1,4.7,4.9,6.1,4.7,'D 450');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Morgan Aero GT','DLC: Car Pass',150000,7.2,7.9,7.1,8.7,7.9,'S1 811');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2010,'Morgan Aero Supersports','Autoshow',160000,7.1,6.3,6.6,8.3,6.3,'A 766');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1953,'Morris Mini-Traveller','HL: Express Delivery - Tier 8',250000,3.7,4,3.5,4.4,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1958,'Morris Minor 1000','Autoshow',20000,4,3.9,3.6,4.9,3.8,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1953,'Morris Minor Series II Traveler','DLC: Fortune Island',25000,3.5,3.9,3.3,3,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Mosler MT900S','Hard-to-Find: Festival reward',320000,8.1,10,8.8,9.9,10,'S2 957');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1933,'Napier-Railton','Hard-to-Find: Festival reward',1000000,7.1,5.1,5.3,6.8,5.6,'B 628');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1993,'Nissan 240SX SE','Autoshow',25000,5.9,4.8,5.1,6.7,4.6,'D 449');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2010,'Nissan 370Z','Autoshow',40000,7.2,6.3,6.2,7.9,5.7,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2003,'Nissan Fairlady Z','Autoshow',35000,7.1,6,6.1,7.7,5.1,'B 671');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'Nissan Fairlady Z 432','Autoshow',150000,5.4,4.7,5.4,6.4,4.6,'D 439');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1994,'Nissan Fairlady Z Version S Twin Turbo','Hard-to-Find: Festival reward',250000,6.7,6,6,7.7,5.5,'B 655');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Nissan GT-R','Autoshow',132000,7.9,7.2,9.6,10,7.6,'S1 836');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Nissan GT-R Preorder Car','Pre-Order bonus / Gifted',132000,7.9,8.5,10,10,9,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Nissan GT-R Black Edition','Autoshow',105000,8,6.8,9.4,10,7.2,'S1 820');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1995,'Nissan Nismo GT-R LM','Wheelspin reward',1100000,6.6,6.4,6,7.6,5.8,'B 685');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1995,'Nissan Nismo GT-R LM F.E.','Skill Tree: Nissan R390',1350000,7.3,10,7.8,9.2,10,'S1 886');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'Nissan R390','Autoshow',730000,7.6,8.2,7.3,7.8,8.5,'S1 877');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Nissan Sentra Nismo','DLC: Car Pass',24000,5.8,6.1,5.8,7.4,6.2,'C 588');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1992,'Nissan Silvia Club K''s','Autoshow',25000,6.2,4.9,5.5,7,4.6,'C 525');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1994,'Nissan Silvia K''s','Autoshow',25000,6.5,5.4,5.9,7.5,5,'C 600');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1998,'Nissan Silvia K''s Aero','Autoshow',25000,6.5,5.5,5.9,7.5,5,'C 593');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2000,'Nissan Silvia Spec-R','Autoshow',35000,6.6,6.1,6.1,7.7,5.2,'B 643');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1971,'Nissan Skyline 2000GT-R','Autoshow',60000,5.6,4.6,5.4,6.4,4.5,'D 455');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1993,'Nissan Skyline GT-R V-Spec','Autoshow',85000,6.5,5.4,6.2,7.7,5.6,'B 620');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1997,'Nissan Skyline GT-R V-Spec','Autoshow',37000,6.9,5.6,6.5,8,5.5,'B 633');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2002,'Nissan Skyline GT-R V-Spec II','HL: Street Scene - Tier 4',63000,6.8,6,6.5,8.1,6,'B 691');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1987,'Nissan Skyline GTS-R (R31)','Autoshow',100000,6.4,4.9,5.7,7.2,4.6,'C 538');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1973,'Nissan Skyline H/T 2000GT-R','Autoshow',170000,5.6,5,5.2,6.1,4.7,'D 494');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Nissan Titan Warrior Concept','Autoshow',50000,5.6,5,5,7.3,4.8,'D 491');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2016,'Nissan Titan Warrior Concept F.E.','DLC: VIP Membership',300000,5.6,6.2,5.2,7.2,5.8,'C 583');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Noble M600','HL: Speed Trap Hero - Tier 11',450000,8.8,8.8,7.8,9.3,9,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'Oldsmobile Hurst/Olds 442','Autoshow',65000,5.8,4.4,5,6.3,4.3,'C 520');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1963,'Opel Kadett A','DLC: Car Pass',25000,4.2,3.9,3.8,5.5,3.8,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1984,'Opel Manta 400','Autoshow',100000,6.6,6.8,6.3,7.9,7,'A 740');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2012,'Pagani Huayra','Autoshow',1300000,8.8,8.4,7.4,8.9,8.8,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Pagani Huayra BC','Autoshow',1500000,8.9,9.8,8,9.4,10,'S2 961');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2009,'Pagani Zonda Cinque Roadster','Autoshow',2100000,7.8,9.5,7.4,8.9,10,'S2 908');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2010,'Pagani Zonda R','Autoshow',1700000,8.2,10,8.2,9.5,10,'S2 966');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2010,'Pagani Zonda R F.E.','DLC: VIP Membership',1950000,8.9,10,8.1,9.5,10,'S2 986');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1962,'Peel P50','Barn Find',20000,3,3,3.2,4.9,7,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1965,'Peel Trident','DLC: Car Pass',25000,3,3,3.2,4.5,5.4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2011,'Penhall The Cholla','HL:oss Country - Tier 14',100000,5.1,6.4,7.2,8.5,6.3,'B 646');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1984,'Peugeot 205 T16','Autoshow',200000,5.8,5.4,6,6.6,5.5,'C 597');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1984,'Peugeot 205 T16 F.E.','Wheelspin reward',450000,6.9,8.3,10,9.3,8.4,'S1 899');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1958,'Plymouth Atomic Punk Bubbletop','DLC: Barrett-Jackson Car Pack',105000,7.1,5.8,6.2,7.4,4.9,'A 717');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1971,'Plymouth Cuda 426 Hemi','Autoshow',160000,6.4,4.7,5.2,6.5,4.3,'C 560');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1957,'Plymouth Fury','Hard-to-Find: Festival reward',250000,6.1,4.5,5.1,6.5,4.4,'C 518');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1970,'Plymouth Hemi Cuda Convertible Barrett-Jackson Edition','DLC: Barrett-Jackson Car Pack',55000,6.4,5.6,5.7,7.2,5.2,'B 689');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2015,'Polaris RZR XP 1000 EPS','Autoshow',25000,4.5,5.8,5.5,7.1,6.2,'D 464');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1977,'Pontiac Firebird Trans Am','Autoshow',45000,6,4.5,5,6.1,4.2,'D 431');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1987,'Pontiac Firebird Trans Am GTA','Autoshow',25000,6.2,4.8,5.4,6.8,4.5,'C 505');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1973,'Pontiac Firebird Trans Am SD-455','Wheelspin reward',61000,6.3,4.7,5.1,6.5,4.4,'C 536');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1965,'Pontiac GTO','Hard-to-Find: Festival reward',48000,5.6,4.3,5,6.3,4.3,'C 514');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1969,'Pontiac GTO Judge','Autoshow',90000,5.8,4.4,5,6.3,4.3,'C 514');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1970,'Porsche #3 917 LH','Hard-to-Find: Festival reward',250000,8.5,7,8,9.4,6.4,'S1 868');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1971,'Porsche #23 917/20','Autoshow',10000000,8.3,7.1,8,9.5,6.6,'S1 861');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1951,'Porsche #46 356 SL GmÃ¼nd Coupe','Hard-to-Find: Festival reward',250000,4.6,4.8,3.9,6.4,4.6,'D 199');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1986,'Porsche #185 959 Prodrive Rally Raid','DLC: Car Pass',205000,6.8,6.9,8.8,10,7.1,'A 779');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1957,'Porsche 356A Speedster','Autoshow',300000,4.7,4.1,4.1,6.8,3.8,'D 185');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1959,'Porsche 356 A 1600 Super','DLC: Car Pass',240000,4.9,4,3.8,6.1,3.7,'D 180');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1964,'Porsche 356 C Cabriolet Emory Special','Hard-to-Find: Festival reward',250000,6.1,5.9,6.8,8.4,5.7,'B 687');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1955,'Porsche 550A Spyder','Autoshow',600000,5.9,4.2,5.4,6.9,3.7,'D 387');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1960,'Porsche 718 RS 60','Autoshow',1000000,6.3,6.5,6.7,7.8,5.5,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Porsche 718 Cayman GTS','Hard-to-Find: Festival reward',250000,7.3,7.5,7.3,8.9,8,'S1 808');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1966,'Porsche 906 Carrera 6','Hard-to-Find: Festival reward',250000,6.8,6.5,6.9,8.1,5.5,'A 748');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1995,'Porsche 911 Carrera 2 by Gunther Werks','HL: Horizon Promo - Tier 11',500000,7.2,7.6,8.3,7.6,8,'S1 823');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1973,'Porsche 911 Carrera RS','Autoshow',200000,6.1,5.7,6.7,8.1,5,'B 631');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'Porsche 911 Carrera S','DLC: Car Pass',105000,7.8,8.1,7.4,8.9,8.4,'S1 840');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'Porsche 911 GT1 Strassenversion','Autoshow',2500000,7.6,8.2,7.1,8.7,8.8,'S1 850');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1995,'Porsche 911 GT2','Autoshow',550000,7.1,6.6,7.6,9.2,7,'A 774');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Porsche 911 GT2 RS','Autoshow',240000,8,8.3,8.7,9.9,8.9,'S1 882');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2018,'Porsche 911 GT2 RS','Autoshow',315000,8.2,8.8,8.4,9.7,9.4,'S2 910');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2004,'Porsche 911 GT3','Autoshow',65000,7.5,7.2,7.8,9.1,7.6,'S1 803');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Porsche 911 GT3 RS','Autoshow',235000,8,9.6,8.4,9.6,10,'S2 904');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Porsche 911 GT3 RS Preorder Car','Pre-Order bonus / HL: The Eliminator - Tier 20',235000,8.6,10,8.7,9.9,10,'S2 998');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2019,'Porsche 911 GT3 RS','Hard-to-Find: Festival reward',255000,8.3,9.7,8.3,9.6,10,'S2 915');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2012,'Porsche 911 GT3 RS 4.0','Autoshow',200000,7.8,8.1,8.6,9.8,8.7,'S1 847');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1982,'Porsche 911 Turbo 3.3','Autoshow',150000,6.4,5.9,6.5,6.7,5.6,'B 688');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Porsche 911 Turbo S','Autoshow',150000,8.3,6.6,9.1,10,7.2,'S1 827');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1970,'Porsche 914/6','Hard-to-Find: Festival reward',24000,5.3,4.7,5.2,7,4.2,'D 408');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2014,'Porsche 918 Spyder','Autoshow',850000,8.9,9.2,10,10,9.7,'S2 942');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1989,'Porsche 944 Turbo','Autoshow',35000,6.5,5.9,6.5,8.1,6,'B 659');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1987,'Porsche 959','Autoshow',400000,7.7,6.3,9,10,6.7,'A 784');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1993,'Porsche 968 Turbo S','DLC: Car Pass',140000,6.9,6.1,6.6,8.3,6.2,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2003,'Porsche Carrera GT','Autoshow',400000,8,8.1,7.5,9,8.6,'S1 866');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2012,'Porsche Cayenne Turbo','Autoshow',110000,7.1,6,7.7,9.5,6.3,'A 740');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Porsche Cayenne Turbo','Wheelspin reward',220000,7.2,6.5,8.7,10,7.1,'A 769');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Porsche Cayman GT4','Autoshow',85000,7.5,8.3,7.8,9.3,8.8,'S1 840');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Porsche Cayman GTS','HL: Road Racing - Tier 8',80000,7.1,7.2,7,8.6,7.5,'A 791');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Porsche Macan Turbo','Autoshow',105000,6.7,6,7,8.9,6.4,'A 708');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2019,'Porsche Macan Turbo','Hard-to-Find: Festival reward',105000,6.9,5.9,7.3,10,6.2,'A 720');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'Porsche Panamera Turbo','Autoshow',150000,7.9,6.6,8.5,10,7.2,'A 789');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',723,'Quartz Regalia','Hard-to-Find: Festival reward',100000,6.2,5.9,7,9,5.6,'B 675');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',723,'Quartz Regalia Type-D','Skill Tree: Quartz Regalia',500000,5,6.5,6.7,9.8,6.5,'C 597');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Radical RXC Turbo','Autoshow',330000,7.3,10,8,9.4,10,'S2 958');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2017,'RAM 1500 Rebel TRX Concept','DLC: Fortune Island',100000,6,6.2,7.7,9.2,6.9,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2017,'RAM 2500 Power Wagon','HL: Dirt Racing - Tier 8',47000,6.1,5.2,4.7,5.2,5.1,'C 518');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1972,'Reliant Supervan III','Autoshow',35000,3.9,3.3,4.1,5.4,3.6,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1980,'Renault 5 Turbo','Autoshow',120000,5.5,5,6.3,8,4.8,'C 512');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1980,'Renault 5 Turbo F.E.','Wheelspin reward',316000,7.5,8.5,8.8,10,9.3,'S1 900');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1973,'Renault Alpine A110 1600s','HL: Dirt Racing - Tier 16',98000,5.9,5.1,5.8,7.2,4.6,'C 522');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2010,'Renault Clio R.S.','Autoshow',25000,5.9,5.8,5.8,7.4,5.5,'C 598');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2010,'Renault Clio R.S. F.E.','Wheelspin reward',275000,5.9,7.7,6.2,7.7,7.7,'A 701');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2016,'Renault Clio R.S. 16 Concept','Hard-to-Find: Festival reward',250000,6.4,7.3,6.5,8.1,7.4,'A 731');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2007,'Renault Clio RS 197','Hard-to-Find: Festival reward',250000,5.9,6.1,5.6,6.9,6.3,'C 592');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2013,'Renault Clio R.S. 200 EDC','Autoshow',29000,5.9,6,6,7.6,6.1,'B 606');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1993,'Renault Clio Williams','HL: Street Scene - Tier 8',30000,5.6,5.2,5.7,7.3,4.9,'C 502');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'Renault MÃ©gane R26.R','HL: The Eliminator - Tier 10',250000,6.2,7,6.3,7.9,7.2,'A 704');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'Renault Megane R.S.','Hard-to-Find: Festival reward',250000,6.5,7,6,7.6,7.1,'A 702');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2010,'Renault Megane R.S. 250','Autoshow',30000,6.3,6.4,6.1,7.8,6.5,'B 666');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2003,'Renault Sport Clio V6','Hard-to-Find: Festival reward',250000,6.3,5.9,5.9,7.3,5.6,'B 627');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2019,'Rimac Concept Two','Hard-to-Find: Festival reward',2000000,9.3,8.1,10,10,8.5,'S2 994');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'RJ Anderson #37 Polaris RZR-Rockstar Energy Pro 2 Truck','Autoshow',500000,6.6,6.7,6.2,7.6,6.5,'S1 815');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Rossion Q1','Hard-to-Find: Festival reward',250000,7.5,8.3,7.6,9.1,8.7,'S1 855');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1984,'Rover SD1 Vitesse','Hard-to-Find: Festival reward',250000,5.8,5.1,5,5.9,4.7,'D 498');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2010,'Saleen S5S Raptor','DLC: Fortune Island (Treasure Chest #8)',180000,8.4,8,7.9,9.4,8.3,'S1 873');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2004,'Saleen S7','Autoshow',388000,8.3,8.2,7.8,9.3,8.4,'S1 879');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,'Shelby Cobra 427 S/C','Autoshow',2100000,6.6,5.4,5.9,7.5,4.8,'B 700');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1965,'Shelby Cobra Daytona Coupe','Autoshow',8000000,7.3,5,5.5,6.5,4.8,'B 645');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1963,'Shelby Monaco King Cobra','DLC: Barrett-Jackson Car Pack',550000,7.4,7.2,7.1,8.7,6.5,'S1 837');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Spania GTA Spano','Autoshow',800000,9,8.7,7.7,9.1,9.3,'S2 931');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Subaru #199 WRX STI VT15R Rally Car','Autoshow',300000,5.9,7.7,8.8,10,8,'A 762');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2013,'Subaru BRZ','Autoshow',32000,6.4,5.2,5.8,7.3,4.7,'C 562');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'Subaru Impreza 22B STi','Barn Find',110000,6.4,6,6.6,8.5,5.5,'B 650');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2004,'Subaru Impreza WRX STi','Wheelspin reward',28000,6.6,5.8,7.5,9.4,5.5,'B 670');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2005,'Subaru Impreza WRX STI','Autoshow',51000,6.7,5.9,7.7,9.5,5.5,'B 694');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2008,'Subaru Impreza WRX STI','Autoshow',31000,6.4,6,6.9,9.2,6.1,'B 681');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1990,'Subaru Legacy RS','Autoshow',25000,6.1,4.8,5.6,7.4,4.9,'C 503');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Subaru WRX STI','Autoshow',33000,6.7,6,6.7,8.5,6,'B 682');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Subaru WRX STI','Autoshow',42000,6.7,6,7,8.8,6.1,'B 693');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1967,'Sunbeam Tiger','Autoshow',65000,5.8,4.5,5.6,7.1,4.5,'D 500');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1979,'Talbot Sunbeam Lotus','Autoshow',25000,5.3,4.6,5.4,6.9,4.7,'D 469');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Tamo Racemo','Autoshow',600000,5.9,5.7,6.1,7.8,5.6,'C 577');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2014,'Terradyne Gurkha LAPV','Autoshow',450000,5,5.1,3.5,4.1,5.3,'D 223');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2014,'Top Gear Track-Tor','HL: Top Gear - Tier 5',250000,5.2,6.9,6.8,8.4,5.9,'C 577');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1993,'Toyota #1 T100 Baja Truck','Autoshow',500000,5.6,6.6,7.4,9.2,6.5,'A 732');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1969,'Toyota 2000GT','Hard-to-Find: Festival reward',750000,6,4.6,5.5,7,4.4,'D 447');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2007,'Toyota Hilux Arctic Trucks AT38','Autoshow',55000,5,6.7,4.6,5.8,5.7,'C 516');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Toyota Landuiser Arctic Trucks AT37','Autoshow',83000,5,6.3,4.3,5.1,5.3,'D 444');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1985,'Toyota Sprinter Trueno GT Apex','Hard-to-Find: Festival reward',250000,5.4,4.7,5.6,7.2,4.5,'D 444');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1992,'Toyota Supra 2.0 GT Twin Turbo','Hard-to-Find: Festival reward',250000,6.2,5.1,5.8,7.5,4.7,'C 543');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'Toyota Supra RZ','Autoshow',250000,7.1,6.1,6.2,7.8,5.6,'B 693');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1962,'Triumph Spitfire','Barn Find',20000,5,3.9,5,6.3,3.7,'D 203');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1962,'Triumph TR3B','DLC: Car Pass',25000,4.8,4.4,3.9,5.8,4.3,'D 243');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1970,'Triumph TR6 PI','DLC: Car Pass',25000,5.5,4.6,5,6.3,4.5,'D 419');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1998,'TVR Cerbera Speed 12','Barn Find',500000,9,7.7,6.6,8.2,7.7,'S1 874');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2018,'TVR Griffith','DLC: Car Pass',105000,7.7,7.9,6.9,8.6,8.3,'S1 844');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2005,'TVR Sagaris','Autoshow',86000,7.2,7.1,6.4,8.1,7,'A 797');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',2005,'TVR Sagaris F.E.','Skill Tree: TVR Sagaris',336000,7.9,9.4,7.9,9.4,9.1,'S2 902');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2001,'TVR Tuscan S','Hard-to-Find: Festival reward',250000,7.1,6.3,6.6,8.2,6.3,'A 747');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2015,'Ultima Evolution Coupe 1020','HL: The Drag Strip - Tier 4',130000,9,10,8.6,9.8,10,'S2 998');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2012,'Vauxhall Astra VXR','Autoshow',25000,6.5,6.3,6.1,7.8,6.7,'B 684');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2009,'Vauxhall Corsa VXR','Hard-to-Find: Festival reward',250000,6.1,5.9,5.3,7.4,5.1,'C 600');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2016,'Vauxhall Corsa VXR','Autoshow',28000,5.9,6.1,5.2,7.5,6.3,'B 610');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2010,'Vauxhall Insignia VXR','DLC: Car Pass',42000,7.1,6,6.8,8.6,6,'B 676');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1990,'Vauxhall Lotus Carlton','Autoshow',70000,7.2,5.4,5.9,7.6,5.3,'B 665');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2005,'Vauxhall Monaro VXR','Autoshow',25000,7.6,6,6.2,7.8,5.5,'A 716');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2004,'Vauxhall VX220 Turbo','DLC: Car Pass',20000,6.4,6.8,7.1,8.7,6.8,'A 717');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2017,'Volkswagen #34 Volkswagen Andretti Rallycross Beetle','Autoshow',500000,5.7,7.8,10,10,8.1,'S1 869');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2018,'Volkswagen #94 Volkswagen Motorsport I.D R Pikes Peak','Hard-to-Find: Festival reward',250000,6.2,10,10,10,10,'S2 998');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1970,'Volkswagen #1107 Desert Dingo Racing Stock Bug','Autoshow',25000,4.8,6,4.7,6.4,5.2,'D 438');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1963,'Volkswagen Beetle','Autoshow',20000,4.1,4,3.7,3.8,3.8,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',1969,'Volkswagen Class 5/1600 Baja Bug','Autoshow',60000,4.6,6.3,4.5,7.2,6.1,'D 407');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1995,'Volkswagen Corrado VR6','Autoshow',20000,6.2,5.2,5.5,7.1,4.8,'C 535');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',1966,'Volkswagen Double Cab Pick-Up','DLC: Car Pass',50000,3.8,4,3.6,3.7,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2014,'Volkswagen Global RallyCross Beetle','Wheelspin reward',500000,6.1,7.6,10,10,7.9,'S1 846');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1983,'Volkswagen Golf GTI','Autoshow',20000,5.2,4.7,5.4,6.9,4.6,'D 408');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1992,'Volkswagen Golf Gti 16v Mk2','Autoshow',20000,5.5,5,5.2,6.5,4.7,'D 454');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2010,'Volkswagen Golf R','Wheelspin reward',64000,6.5,5.8,6.6,8.3,5.1,'B 661');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2014,'Volkswagen Golf R','Autoshow',50000,6.6,6,7.3,8.9,5.6,'B 672');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2003,'Volkswagen Golf R32','Autoshow',20000,6.4,5.8,6.6,8.6,5.4,'B 630');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1998,'Volkswagen GTI VR6 Mk3','Autoshow',25000,5.9,5.1,5.5,6.9,5.1,'C 512');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1967,'Volkswagen Karmann Ghia','Hard-to-Find: Festival reward',250000,4.2,4.5,3.7,5.4,4.6,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2011,'Volkswagen Scirocco R','Autoshow',45000,6.5,6.2,6,7.7,6.2,'B 678');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1981,'Volkswagen Scirocco S','Autoshow',20000,4.8,4.6,4.4,6.4,4.5,'D 264');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',2008,'Volkswagen Touareg R50','Autoshow',48000,6.4,5.9,5.5,9,6.3,'B 631');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',1963,'Volkswagen Type 2 De Luxe','Autoshow',40000,3.8,4,3.6,3.9,3.9,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Forza',1963,'Volkswagen Type 2 De Luxe F.E.','Wheelspin reward',290000,3.8,5.9,3.6,3.9,5.7,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1967,'Volkswagen Type 3 1600 L','Hard-to-Find: Festival reward',250000,4.6,4.5,3.8,5.6,4.5,'D 153');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1983,'Volvo 242 Turbo Evolution','Autoshow',45000,5.9,4.5,5.5,7,4.8,'C 512');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1997,'Volvo 850 R','Autoshow',25000,6.5,5,5.1,6.5,4.6,'C 544');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Epic',2016,'Volvo Iron Knight','Autoshow',800000,7.6,5.9,7.3,8.9,6.9,'A 797');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Rare',2015,'Volvo V60 Polestar','Autoshow',62000,6.8,5.5,7,8.9,5.7,'B 652');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'W Motors Lykan HyperSport','Autoshow',3400000,8.7,8.4,7.7,9.2,9,'S2 907');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Common',1945,'Willys MB Jeep','Autoshow',40000,3.9,4.2,4,6,4,'D 100');
INSERT INTO VEC_Vehicle (USR_CreatedBy, COD_Game, VEC_Rarity, VEC_Year, VEC_Name, VEC_Unlock, VEC_Value, VEC_Speed, VEC_Handling, VEC_Acceleration, VEC_Launch, VEC_Breaking, VEC_Performance) VALUES (1, 0, 'Legendary',2016,'Zenvo ST1','HL: World''s Fastest - Tier 10',1000000,8.8,7.9,7.1,8.7,8.4,'S1 900');

-- Cars "manually" assigned to Themes
-- according to https://forums.forzamotorsport.net/turn10_postsm608012_Route-maps--Event-restrictions--Discovery-Lists----April-Rivals.aspx#post_608012
-- (see post >= #17
-- INCOMPLETE!!

-- Sports Utility Heroes
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 27
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'BMW X6 M',
'BMW X5 M',
'Cadillac Escalade ESV',
'Jaguar F-PACE S',
'Jeep Grand Cherokee SRT',
'Lamborghini Urus',
'Land Rover Range Rover Sport SVR',
'Land Rover Range Rover Supercharged',
'Mercedes-Benz G 65 AMG',
'Porsche Cayenne Turbo',
'Porsche Macan Turbo'
)
;

-- Offroad
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 28
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Ford F-150 Raptor Race Truck',
'Ford F-150 Raptor Horizon Edition',
'Ford F-150 Raptor',
'Ford F-150 SVT Raptor Shelby',
'Ford F-150 SVT Raptor',
'Ford Bronco',
'Hummer H1 Alpha',
'International Scout 800A',
'Jeep Wrangler Rubicon',
'Jeep CJ5 Renegade',
'Jeep Willys MB',
'Lamborghini LM 002',
'Land Rover Defender 90',
'Land Rover Series III',
'Nissan Titan Warrior Concept',
'Ram Ram Runner Horizon Edition',
'Ram Ram Runner',
'Terradyne Gurkha LAPV',
'Toyota FJ40'
)
;

-- Offroad Buggies
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 29
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Alumi Craft Class 10 Race Car',
'Ariel Nomad',
'Hot Wheels Rip Rod',
'Penhall The Cholla',
'Polaris RZR XP 1000 EPS Rockstar Edition',
'Polaris RZR XP 1000 EPS Horizon Edition',
'Polaris RZR XP 1000 EPS'
)
;

-- Extreme Offroad
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 26
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'AMG TD M12S Warthog CST',
'Baldwin #97 Monster Energy Trophy Truck',
'Bowler EXR S',
'Ford Ranger T6 Rally Raid',
'Ford F-100 Flareside Abatti Racing Trophy Truck',
'Jeep Trailcat',
'Local Motors Rally Fighter',
'MINI Monster Energy All4 Racing Countryman',
'RJ Anderson #37 Polaris RZR-Rockstar Energy Pro 2 Truck',
'Toyota Hilux Arctic Trucks AT38'
)
;

-- Cult Classics
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 10
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Abarth 595 esseesse',
'AMC Gremlin X',
'BMW 2002 Turbo',
'BMW Isetta 300 Export',
'Chevrolet Corvette',
'Chevrolet Corvette',
'Datsun 510',
'Datsun 2000 Roadster',
'FIAT 124 Sport Spider',
'FIAT X1/9',
'Ford Capri RS3100',
'Holden FX Sedan',
'Honda S800',
'Jaguar XJ-S',
'Jeep Grand Wagoneer',
'Mazda Cosmo 110S Series II',
'Meyers Manx',
'Morgan 3 Wheeler',
'Nissan Skyline H/T 2000GT-R',
'Nissan Skyline 2000GT-R',
'Nissan Fairlady Z 432',
'Nissan Silvia',
'Reliant Supervan III',
'Renault Alpine GTA Le Mans',
'Toyota Corolla SR5',
'Toyota Celica GT',
'Volvo 123GT'
)
;

-- Rods and Customs
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 17
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Chevrolet Impala Super Sport 409',
'Chevrolet Bel Air',
'Ford F-100',
'Ford De Luxe Coupe',
'Ford De Luxe Five-Window Coupe',
'Hot Wheels Bone Shaker',
'Hot Wheels Twin Mill',
'Mercury Coupe',
'Plymouth Fury'
)
;

-- Classic Muscle
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 16
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'AMC Javelin-AMX',
'AMC Rebel "The Machine"',
'Chevrolet Camaro Z28',
'Chevrolet Vega GT',
'Chevrolet Corvette',
'Chevrolet Chevelle Super Sport 454 Horizon Edition',
'Chevrolet Chevelle Super Sport 454',
'Chevrolet Camaro Z28',
'Chevrolet Camaro Super Sport Coupe Horizon Edition',
'Chevrolet Camaro Super Sport Coupe',
'Chevrolet Corvette',
'Chevrolet Chevelle Super Sport 396',
'Chevrolet Nova Super Sport',
'Chrysler VH Valiant Charger R/T E49',
'Dodge Challenger R/T',
'Dodge Charger R/T',
'Dodge Charger Daytona HEMI',
'Dodge Dart HEMI Super Stock Horizon Edition',
'Dodge Dart HEMI Super Stock',
'Ford Mustang II King Cobra',
'Ford XB Falcon GT',
'Ford Falcon XY GTHO Phase III',
'Ford Mustang Boss 302 Horizon Edition',
'Ford Mustang Boss 302',
'Ford Falcon XR GT',
'Ford Super Deluxe Station Wagon',
'Holden Torana Horizon Edition',
'Holden Torana A9X',
'Holden HQ Monaro GTS 350',
'Oldsmobile Hurst/Olds 442',
'Plymouth Cuda 426 Hemi',
'Pontiac Firebird Trans Am',
'Pontiac Firebird Trans Am SD-455',
'Pontiac GTO Judge',
'Pontiac GTO'
)
;

-- Retro Muscle
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 18
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Buick Regal GNX',
'Chevrolet Corvette',
'Chevrolet Camaro IROC-Z',
'Chevrolet Monte Carlo Super Sport',
'Dodge Viper GTS ACR',
'Ford Crown Victoria Police Interceptor',
'Ford SVT Cobra R',
'Ford SVT Cobra R',
'Ford SVT Cobra R',
'HDT VK Commodore Group A',
'Holden VL Commodore Group A SV',
'HSV GTSR',
'Plymouth Prowler',
'Pontiac Firebird Trans Am GTA'
)
;

-- Modern Muscle
INSERT INTO VTT_VehicleTypesThemes
(VEC_CarId, COD_CarTheme)
SELECT
	VEC_CarId, 19
FROM VEC_Vehicle
WHERE
	VEC_Name IN
(
'Cadillac ATS-V',
'Cadillac CTS-V Sedan',
'Cadillac CTS-V Coupe',
'Chevrolet Camaro Super Sport',
'Chevrolet Corvette',
'Chevrolet Corvette',
'Chevrolet Camaro Z/28',
'Chevrolet Super Sport',
'Chevrolet Corvette',
'Chevrolet Corvette',
'Chrysler 300 SRT8',
'Dodge Viper ACR',
'Dodge Charger SRT Hellcat Pre-Order Edition',
'Dodge Charger SRT Hellcat',
'Dodge Challenger SRT Hellcat Horizon Edition',
'Dodge Challenger SRT Hellcat',
'Dodge Viper SRT10 ACR Horizon Edition',
'Dodge Viper SRT10 ACR',
'Ford Shelby GT350R Pre-Order Edition',
'Ford Shelby GT350R',
'Ford Falcon XR8',
'Ford Falcon GT F 351',
'Ford Shelby GT500',
'HSV GTS',
'SRT Viper GTS'
)
;

-- SGG/ZF77 Community Tracks (imported from Excel)
-- ACHTUNG: phpMyAdmin auf dem Server akzeptiert zwar Umlaute und Sonderzeichen,
-- führen dann aber in der Anwendung zu einem Absturz ohne klare Fehlermeldung!!
-- (die services kommen "leer" zurück, kein Content/Response)
-- deshalb mussten Unmlaute und das deutsche ß entfernt werden.
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Highlands to Beach, Sprint', 'PlutoKaskade641', 0, 540, 26.6, 878858666, '', 'Glen Rannoch, Pfad');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Beach to Ambleside, Sprint', 'PlutoKaskade641', 0, 595, 30.1, 388938475, '', 'The Meadows, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Ambleside to Highlands, Sprint', 'PlutoKaskade641', 0, 415, 22.5, 904916263, '', 'Ambleside, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Kleine Rundstrecke 1.0', 'PlutoKaskade641', 0, 0, NULL, NULL, '', 'The Meadows, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Horizon Rundkurs 1.0', 'PlutoKaskade641', 1, 1080, 60.3, 172291707, '', 'Lake District, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Around Edinburgh', 'PlutoKaskade641', 4, 140, 7.5, 101788614, '', 'Nordstadt, Querfeldeinrundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Highspeed-Runde ums Festival', 'PlutoKaskade641', 2, 270, 16.7, 891242477, '', 'Der Goliath');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'See und Highlands Rundfahrt', 'PlutoKaskade641', 2, 455, 26.8, 168058143, '', 'Derwent, Seeufer-Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Fluss-See-Runde', 'rauschi46', 2, 555, 32.5, 443644673, 'Power', 'Gaerten, Querfeldeinrundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Dummer Name', 'rauschi46', 0, 900, 51, 168626152, '', 'Ambleside, Querfeldeinjagd');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Durch n Wald und uebern Acker', 'rauschi46', 0, 675, 38.5, 143839212, '', 'Derwent, Staubecken-Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, '39,3km Rundkurs Strasse', 'Quax2013', 1, 680, 39.3, 167140431, 'Power, Checkpoint!', 'Broadway Dorf, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Fuer Pluto - Schlaengel', 'Quax2013', 4, 195, 4.8, 120067187, 'sehr anspruchsvoll, kleiner Dirt-Teil, max 6 Leute', 'Bamburgh, Kiefernwald-Pfad');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 1', 'MrElvinco', 5, 133, 6.9, 778985861, '2 schwierige Harnadelkurven', 'Waeldchen, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 2', 'MrElvinco', 4, 130, 7.1, 770125318, '', 'Broadway, Dorf-Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 3', 'MrElvinco', 0, 0, NULL, NULL, '', 'Bamburgh, Kueste-Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 4', 'MrElvinco', 2, 370, 20.3, 872808689, 'anspruchsvollere Strecke', 'Moorhead-Windfarm, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 5', 'MrElvinco', 3, 90, 4.8, 550621256, 'kurzes Rennen -> gut zum Einfahren', 'Greendale, Club-Strecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Circuit 6', 'MrElvinco', 6, 120, 5, 147522464, '90° Kurven', 'Broadway, Dorf-Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Tour la Forza', 'XScarface86X', 0, 1155, 58.6, 121013903, '', 'Greendale, Super Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Rundkurs, Stadt', 'XScarface86X', 3, 200, 8.2, 682007112, '', 'Edinburgh, Bahnhof - Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Bergrunde', 'XScarface86X', 3, 212, 11.3, 110330366, '', 'Glen Rannoch, Huegelstrasse - Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Big Sprint', 'XScarface86X', 0, 960, 52.7, 817670124, '', 'Greendale, Club-Strecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Edinburgh nach Broadway Sprint', 'XScarface86X', 0, 555, 27.6, 619723521, '', 'Princess Street Gardens, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Windpark Runde, Rundkurs', 'XScarface86X', 2, 222, 11.8, 132814264, '', 'Mudkickers-Allrad, Grip-Rennen');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Festivalrunde, Rundkurs', 'XScarface86X', 2, 122, 5.7, 565069661, '', 'Ambleside, Schleife - Querfeldein');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Goliath V2.0, Sprint', 'XScarface86X', 0, 1230, 64.4, 132124540, '', 'Goliath');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Festivalrunde 2.0, Rundkurs', 'XScarface86X', 2, 150, 7.6, 407103362, '', 'Horizon-Festival, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Windfarm zu Windmuehle, Sprint', 'XScarface86X', 0, 600, 34.6, 322010086, '', 'Moorhead-Windfarm, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Bamburgh to Ambleside, Sprint', 'XScarface86X', 0, 470, 25, 610741906, '', 'Bamburgh, Kueste - Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Pretty Easy, Rundkurs', 'XScarface86X', 2, 175, 9.5, 182131917, '', 'Elmsdon on Sea, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Derwent Speed Kurs, Rundkurs', 'XScarface86X', 2, 184, 13.1, 161299877, '', 'Lake District, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Around The Hill, Rundkurs', 'XScarface86X', 2, 228, 12.8, 152799131, '', 'Glen Rannoch, Querfeldein');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Flugfeld Stadt, Rundkurs', 'XScarface86X', 2, 260, 12, 171789071, '', 'The Meadows, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Odyssee, Rundkurs', 'XScarface86X', 2, 920, 51.5, 170890022, '', 'Glen Rannoch, Huegelstrasse - Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Die Sau, Rundkurs', 'XScarface86X', 3, 312, 18.1, 162256793, '', 'Lakehurst, Wald - Grip-Rennen');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Just One More, Rundkurs', 'XScarface86X', 3, 460, 25, 229473628, '', 'Greendale, Super Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'City Trip, Rundkurs', 'XScarface86X', 4, 230, 10, 168219459, '', 'Greendale, Super Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Ambleside Runde, Rundkurs', 'XScarface86X', 3, 212, 10.8, 171088218, '', 'Ambleside, Dorf - Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Lets Fetz, Sprint', 'XScarface86X', 0, 1010, 50.3, 149482771, '', 'Horizon-Festival, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Mayhem, Rundkurs', 'XScarface86X', 4, 153, 6.6, 133566693, 'mehrere Kreuzungen!', 'Princess Street Gardens, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Der Elch, Rundkurs', 'XScarface86X', 2, 552, 29, 162047596, '', 'The Meadows, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Terminator', 'AndiYTDE', 1, 1005, 57.4, 554402570, '', 'Horizon-Festival, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Edinburgh Grand-Prix', 'AndiYTDE', 5, 75, 3.4, 484645749, 'max. 6 Fahrer', 'Princes Street Gardens, Rundstrecke');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Volker Racho die 2.', 'Joshi140104', 2, 385, 25.7, 342137770, '', 'Lakehurst Forest, Sprint');
INSERT INTO RAT_RacingTrack (USR_CreatedBy, COD_Game, COD_Type, COD_Series, COD_Sharing, COD_CarClass, RAT_Name, RAT_Designer, RAT_Laps, RAT_DefaultLapTimeSec, RAT_DistanceKM, RAT_SharingCode, RAT_Description, RAT_CustomRoute) VALUES (1, 0, 1, 1, 0, 5, 'Curved Curse', 'Nur24hracer', 3, 297, 15.8, 149533035, '', 'Elmsdon on Sea, Sprint');

-- map forza tracks (umlaute/sonderzeichen bereinigt)
UPDATE RAT_RacingTrack a
INNER JOIN RAT_RacingTrack b
	ON b.RAT_Name = case a.RAT_CustomRoute 
		when 'Ambleside, Dorf - Rundstrecke' then 'Ambleside Village Circuit'
		when 'Ambleside, Querfeldeinjagd' then 'Ambleside Rush Cross Country'
		when 'Ambleside, Schleife - Querfeldein' then 'Ambleside Loop Cross Country'
		when 'Ambleside, Sprint' then 'Ambleside Sprint'
		when 'Bamburgh, Kiefernwald-Pfad' then 'Bamburgh Pinewood Trail'
		when 'Bamburgh, Kueste - Rundstrecke' then 'Bamburgh Coast Circuit'
		when 'Bamburgh, Kueste-Rundstrecke' then 'Bamburgh Coast Circuit'
		when 'Broadway Dorf, Rundstrecke' then 'Broadway Village Circuit'
		when 'Broadway, Dorf-Rundstrecke' then 'Broadway Village Circuit'
		when 'Der Goliath' then 'THE GOLIATH'
		when 'Derwent, Seeufer-Sprint' then 'Derwent Lakeside Sprint'
		when 'Derwent, Staubecken-Sprint' then 'Derwent Reservoir Sprint'
		when 'Edinburgh, Bahnhof - Rundstrecke' then 'Edinburgh Station Circuit'
		when 'Elmsdon on Sea, Sprint' then 'Elmsdon on Sea Sprint'
		when 'Gaerten, Querfeldeinrundstrecke' then 'Gardens Cross Country Circuit'
		when 'Glen Rannoch, Huegelstrasse - Sprint' then 'Glen Rannoch Hillside Sprint'
		when 'Glen Rannoch, Pfad' then 'Glen Rannoch Trail'
		when 'Glen Rannoch, Querfeldein' then 'Glen Rannoch Cross Country'
		when 'Goliath' then 'THE GOLIATH'
		when 'Greendale, Club-Strecke' then 'Greendale Club Circuit'
		when 'Greendale, Super Sprint' then 'Greendale Super Sprint'
		when 'Horizon-Festival, Rundstrecke' then 'Horizon Festival Circuit'
		when 'Lake District, Sprint' then 'Lake District Sprint'
		when 'Lakehurst Forest, Sprint' then 'Lakehurst Forest Sprint'
		when 'Lakehurst, Wald - Grip-Rennen' then 'Lakehurst Woodland Scramble'
		when 'Moorhead-Windfarm, Rundstrecke' then 'Moorhead Wind Farm Circuit'
		when 'Mudkickers-Allrad, Grip-Rennen' then 'Mudkickers'' 4x4 Scramble'
		when 'Nordstadt, Querfeldeinrundstrecke' then 'North City Cross Country Circuit'
		when 'Princes Street Gardens, Rundstrecke' then 'Princess Street Gardens Circuit'
		when 'Princess Street Gardens, Rundstrecke' then 'Princess Street Gardens Circuit'
		when 'The Meadows, Sprint' then 'The Meadows Sprint'	
		END
SET
	a.RAT_ForzaRouteId = b.RAT_TrackId
WHERE
	a.COD_Type = 1;
	
-- manual additions (unstructured in sources)
UPDATE RAT_RacingTrack
SET
	COD_Series = 2
WHERE
	RAT_Name IN (
		'Highlands to Beach, Sprint',
		'Fuer Pluto - Schlaengel',
		'Windpark Runde, Rundkurs',
		'Die Sau, Rundkurs'
	)
;

UPDATE RAT_RacingTrack
SET
	COD_Series = 3
WHERE
	RAT_Name IN (
		'Around Edinburgh',
		'Fluss-See-Runde',
		'Dummer Name',
		'Festivalrunde, Rundkurs',
		'Around The Hill, Rundkurs'
	)
;

UPDATE RAT_RacingTrack
	SET RAT_Description = NULL
WHERE
	RAT_Description = ''
;
