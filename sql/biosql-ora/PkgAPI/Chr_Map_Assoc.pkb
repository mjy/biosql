--
-- API Package Body for Chr_Map_Assoc.
--
-- Scaffold auto-generated by gen-api.pl (H.Lapp, 2002).
--
-- $Id: Chr_Map_Assoc.pkb,v 1.1.1.1 2002-08-13 19:51:10 lapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
--
-- You may distribute this module under the same terms as Perl.
-- Refer to the Perl Artistic License (see the license accompanying this
-- software package, or see http://www.perl.com/language/misc/Artistic.html)
-- for the terms under which you may use, modify, and redistribute this module.
-- 
-- THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
-- MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--

CREATE OR REPLACE
PACKAGE BODY ChrEntA IS

ChrEntA_cached	SG_CHR_MAP_ASSOC.OID%TYPE DEFAULT NULL;
cache_key		VARCHAR2(128) DEFAULT NULL;

CURSOR ChrEntA_c (
		ChrEntA_ENT_OID	IN SG_CHR_MAP_ASSOC.ENT_OID%TYPE,
		ChrEntA_CHR_OID	IN SG_CHR_MAP_ASSOC.CHR_OID%TYPE,
		ChrEntA_REL_OID	IN SG_CHR_MAP_ASSOC.REL_OID%TYPE)
RETURN SG_CHR_MAP_ASSOC%ROWTYPE IS
	SELECT t.* FROM SG_CHR_MAP_ASSOC t
	WHERE
		t.ENT_OID = ChrEntA_ENT_OID
	AND	t.CHR_OID = ChrEntA_CHR_OID
	AND	t.REL_OID = ChrEntA_REL_OID
	;

FUNCTION get_oid(
		ChrEntA_OID	IN SG_CHR_MAP_ASSOC.OID%TYPE DEFAULT NULL,
		ChrEntA_CHR_START_POS	IN SG_CHR_MAP_ASSOC.CHR_START_POS%TYPE DEFAULT NULL,
		ChrEntA_CHR_END_POS	IN SG_CHR_MAP_ASSOC.CHR_END_POS%TYPE DEFAULT NULL,
		ChrEntA_ENT_END_POS	IN SG_CHR_MAP_ASSOC.ENT_END_POS%TYPE DEFAULT NULL,
		ChrEntA_ENT_START_POS	IN SG_CHR_MAP_ASSOC.ENT_START_POS%TYPE DEFAULT NULL,
		ChrEntA_STRAND	IN SG_CHR_MAP_ASSOC.STRAND%TYPE DEFAULT NULL,
		ChrEntA_NUM_MISMATCH	IN SG_CHR_MAP_ASSOC.NUM_MISMATCH%TYPE DEFAULT NULL,
		ENT_OID	IN SG_CHR_MAP_ASSOC.ENT_OID%TYPE,
		CHR_OID	IN SG_CHR_MAP_ASSOC.CHR_OID%TYPE,
		REL_OID	IN SG_CHR_MAP_ASSOC.REL_OID%TYPE,
		Ent_ACCESSION	IN SG_BIOENTRY.ACCESSION%TYPE DEFAULT NULL,
		Ent_VERSION	IN SG_BIOENTRY.VERSION%TYPE DEFAULT NULL,
		Ent_IDENTIFIER	IN SG_BIOENTRY.IDENTIFIER%TYPE DEFAULT NULL,
		DB_OID		IN SG_BIOENTRY.DB_OID%TYPE DEFAULT NULL,
		DB_NAME		IN SG_BIODATABASE.NAME%TYPE DEFAULT NULL,
		DB_ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE DEFAULT NULL,
		Rel_VERSION	IN SG_DB_RELEASE.VERSION%TYPE DEFAULT NULL,
		Rel_DB_OID	IN SG_DB_RELEASE.DB_OID%TYPE DEFAULT NULL,
		Rel_DB_NAME	IN SG_BIODATABASE.NAME%TYPE DEFAULT NULL,
		Rel_DB_ACRONYM	IN SG_BIODATABASE.ACRONYM%TYPE DEFAULT NULL,
		Chr_NAME	IN SG_CHROMOSOME.NAME%TYPE DEFAULT NULL,
		TAX_OID		IN SG_CHROMOSOME.TAX_OID%TYPE DEFAULT NULL,
		Tax_NAME	IN SG_TAXON.NAME%TYPE DEFAULT NULL,
		Tax_NCBI_TAXON_ID IN SG_TAXON.NCBI_TAXON_ID%TYPE DEFAULT NULL,
		do_DML		IN NUMBER DEFAULT BSStd.DML_NO)
RETURN SG_CHR_MAP_ASSOC.OID%TYPE
IS
	pk	SG_CHR_MAP_ASSOC.OID%TYPE DEFAULT NULL;
	ChrEntA_row ChrEntA_c%ROWTYPE;
	ENT_OID_	SG_BIOENTRY.OID%TYPE DEFAULT ENT_OID;
	REL_OID_	SG_DB_RELEASE.OID%TYPE DEFAULT REL_OID;
	CHR_OID_	SG_CHROMOSOME.OID%TYPE DEFAULT CHR_OID;
BEGIN
	-- initialize
	IF (do_DML > BSStd.DML_NO) THEN
		pk := ChrEntA_OID;
	END IF;
	-- look up SG_CHROMOSOME
	IF (CHR_OID_ IS NULL) THEN
		CHR_OID_ := Chrom.get_oid(
				Chr_NAME => Chr_NAME,
				TAX_OID => TAX_OID,
				Tax_NAME => Tax_NAME,
				Tax_NCBI_TAXON_ID => Tax_NCBI_TAXON_ID,
				do_DML => do_DML);
	END IF;
	-- look up SG_BIOENTRY
	IF (ENT_OID_ IS NULL) THEN
		ENT_OID_ := Ent.get_oid(
				Ent_ACCESSION => Ent_ACCESSION,
				Ent_VERSION => Ent_VERSION,
				DB_OID => DB_OID,
				Ent_IDENTIFIER => Ent_IDENTIFIER,
				DB_NAME => DB_NAME,
				DB_ACRONYM => DB_ACRONYM);
	END IF;
	-- look up SG_DB_RELEASE
	IF (REL_OID_ IS NULL) THEN
		REL_OID_ := Rel.get_oid(
			        Rel_VERSION => Rel_VERSION,
			        DB_OID => Rel_DB_OID,
				DB_NAME => Rel_DB_NAME,
				DB_ACRONYM => Rel_DB_ACRONYM,
				do_DML => do_DML);
	END IF;
	-- look up
	IF pk IS NULL THEN
		-- do the look up
		FOR ChrEntA_row IN ChrEntA_c(ENT_OID_, CHR_OID_, REL_OID_) LOOP
	        	pk := ChrEntA_row.OID;
		END LOOP;
	END IF;
	-- insert/update if requested
	IF (pk IS NULL) AND 
	   ((do_DML = BSStd.DML_I) OR (do_DML = BSStd.DML_UI)) THEN
	    	-- look up foreign keys if not provided:
		-- look up SG_BIOENTRY successful?
		IF (ENT_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Ent <' || Ent_ACCESSION || '|' || Ent_VERSION || '|' || DB_OID || '|' || Ent_IDENTIFIER || '>');
		END IF;
		-- look up SG_DB_RELEASE successful?
		IF (REL_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Rel <' || Rel_VERSION || '|' || Rel_DB_OID || '>');
		END IF;
		-- look up SG_CHROMOSOME successful?
		IF (CHR_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Chr <' || Chr_NAME || '|' || TAX_OID || '>');
		END IF;
	    	-- insert the record and obtain the primary key
	    	pk := do_insert(
		        CHR_START_POS => ChrEntA_CHR_START_POS,
			CHR_END_POS => ChrEntA_CHR_END_POS,
			ENT_END_POS => ChrEntA_ENT_END_POS,
			ENT_START_POS => ChrEntA_ENT_START_POS,
			STRAND => ChrEntA_STRAND,
			NUM_MISMATCH => ChrEntA_NUM_MISMATCH,
			ENT_OID => ENT_OID_,
			CHR_OID => CHR_OID_,
			REL_OID => REL_OID_);
	ELSIF (do_DML = BSStd.DML_U) OR (do_DML = BSStd.DML_UI) THEN
	        -- update the record
		do_update(
			ChrEntA_OID	=> pk,
		        ChrEntA_CHR_START_POS => ChrEntA_CHR_START_POS,
			ChrEntA_CHR_END_POS => ChrEntA_CHR_END_POS,
			ChrEntA_ENT_END_POS => ChrEntA_ENT_END_POS,
			ChrEntA_ENT_START_POS => ChrEntA_ENT_START_POS,
			ChrEntA_STRAND => ChrEntA_STRAND,
			ChrEntA_NUM_MISMATCH => ChrEntA_NUM_MISMATCH,
			ChrEntA_ENT_OID => ENT_OID_,
			ChrEntA_CHR_OID => CHR_OID_,
			ChrEntA_REL_OID => REL_OID_);
	END IF;
	-- return the primary key
	RETURN pk;
END;

FUNCTION do_insert(
		CHR_START_POS	IN SG_CHR_MAP_ASSOC.CHR_START_POS%TYPE,
		CHR_END_POS	IN SG_CHR_MAP_ASSOC.CHR_END_POS%TYPE,
		ENT_END_POS	IN SG_CHR_MAP_ASSOC.ENT_END_POS%TYPE,
		ENT_START_POS	IN SG_CHR_MAP_ASSOC.ENT_START_POS%TYPE,
		STRAND	IN SG_CHR_MAP_ASSOC.STRAND%TYPE,
		NUM_MISMATCH	IN SG_CHR_MAP_ASSOC.NUM_MISMATCH%TYPE,
		ENT_OID	IN SG_CHR_MAP_ASSOC.ENT_OID%TYPE,
		CHR_OID	IN SG_CHR_MAP_ASSOC.CHR_OID%TYPE,
		REL_OID	IN SG_CHR_MAP_ASSOC.REL_OID%TYPE)
RETURN SG_CHR_MAP_ASSOC.OID%TYPE 
IS
	pk	SG_CHR_MAP_ASSOC.OID%TYPE;
BEGIN
	-- pre-generate the primary key value
	SELECT SG_Sequence.nextval INTO pk FROM DUAL;
	-- insert the record
	INSERT INTO SG_CHR_MAP_ASSOC (
		OID,
		CHR_START_POS,
		CHR_END_POS,
		ENT_END_POS,
		ENT_START_POS,
		STRAND,
		NUM_MISMATCH,
		ENT_OID,
		CHR_OID,
		REL_OID)
	VALUES (pk,
		CHR_START_POS,
		CHR_END_POS,
		ENT_END_POS,
		ENT_START_POS,
		STRAND,
		NUM_MISMATCH,
		ENT_OID,
		CHR_OID,
		REL_OID)
	;
	-- return the primary key
	RETURN pk;
END;

PROCEDURE do_update(
		ChrEntA_OID	IN SG_CHR_MAP_ASSOC.OID%TYPE,
		ChrEntA_CHR_START_POS	IN SG_CHR_MAP_ASSOC.CHR_START_POS%TYPE,
		ChrEntA_CHR_END_POS	IN SG_CHR_MAP_ASSOC.CHR_END_POS%TYPE,
		ChrEntA_ENT_END_POS	IN SG_CHR_MAP_ASSOC.ENT_END_POS%TYPE,
		ChrEntA_ENT_START_POS	IN SG_CHR_MAP_ASSOC.ENT_START_POS%TYPE,
		ChrEntA_STRAND	IN SG_CHR_MAP_ASSOC.STRAND%TYPE,
		ChrEntA_NUM_MISMATCH	IN SG_CHR_MAP_ASSOC.NUM_MISMATCH%TYPE,
		ChrEntA_ENT_OID	IN SG_CHR_MAP_ASSOC.ENT_OID%TYPE,
		ChrEntA_CHR_OID	IN SG_CHR_MAP_ASSOC.CHR_OID%TYPE,
		ChrEntA_REL_OID	IN SG_CHR_MAP_ASSOC.REL_OID%TYPE)
IS
BEGIN
	-- update the record (and leave attributes passed as NULL untouched)
	UPDATE SG_CHR_MAP_ASSOC
	SET
		CHR_START_POS = NVL(ChrEntA_CHR_START_POS, CHR_START_POS),
		CHR_END_POS = NVL(ChrEntA_CHR_END_POS, CHR_END_POS),
		ENT_END_POS = NVL(ChrEntA_ENT_END_POS, ENT_END_POS),
		ENT_START_POS = NVL(ChrEntA_ENT_START_POS, ENT_START_POS),
		STRAND = NVL(ChrEntA_STRAND, STRAND),
		NUM_MISMATCH = NVL(ChrEntA_NUM_MISMATCH, NUM_MISMATCH),
		ENT_OID = NVL(ChrEntA_ENT_OID, ENT_OID),
		CHR_OID = NVL(ChrEntA_CHR_OID, CHR_OID),
		REL_OID = NVL(ChrEntA_REL_OID, REL_OID)
	WHERE OID = ChrEntA_OID
	;
END;

PROCEDURE update_ent_positions
IS
BEGIN
	UPDATE SG_Chr_Map_Assoc ChrEntA
	SET
		Ent_Start_Pos = 0,
		Ent_End_Pos = (
			    SELECT Seq.Length FROM SG_Biosequence Seq
			    WHERE Seq.Oid = ChrEntA.Ent_Oid
		)
	WHERE Ent_Start_Pos IS NULL AND Ent_End_Pos IS NULL
	AND   Ent_Oid IN (
	    SELECT bs.Oid FROM SG_Biosequence bs 
	    WHERE bs.Oid = ChrEntA.Ent_Oid AND bs.Length IS NOT NULL
	)
	;
END;

END ChrEntA;
/
