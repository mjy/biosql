-- -*-Sql-*- mode (to keep my emacs happy)
--
-- API Package Body for Term.
--
-- Scaffold auto-generated by gen-api.pl. gen-api.pl is
-- (c) Hilmar Lapp, lapp@gnf.org, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/Term.pkb,v 1.6 2003/06/06 03:27:34 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2003.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2003.
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
PACKAGE BODY Trm IS

Trm_cached	SG_TERM.OID%TYPE DEFAULT NULL;
cache_key		VARCHAR2(512) DEFAULT NULL;

--TYPE Id_Hash IS TABLE OF SG_TERM.OID%TYPE INDEX BY SG_TERM.IDENTIFIER%TYPE;
TYPE Id_Hash IS TABLE OF SG_TERM.OID%TYPE INDEX BY VARCHAR2(512);
trm_id_hash Id_Hash;

CURSOR Trm_c (
		Trm_NAME	IN SG_TERM.NAME%TYPE,
		Trm_ONT_OID	IN SG_TERM.ONT_OID%TYPE)
RETURN SG_TERM%ROWTYPE IS
	SELECT t.* FROM SG_TERM t
	WHERE
		t.NAME = Trm_NAME
		-- allow for omission of the ontology OID
	AND	t.ONT_OID = NVL(Trm_ONT_OID, ONT_OID)
	;

CURSOR Trm_Id_c (
		Trm_IDENTIFIER	IN SG_TERM.IDENTIFIER%TYPE)
RETURN SG_TERM%ROWTYPE IS
	SELECT t.* FROM SG_TERM t
	WHERE
		t.IDENTIFIER = Trm_IDENTIFIER
	;

FUNCTION get_oid(
		Trm_OID	IN SG_TERM.OID%TYPE DEFAULT NULL,
		Trm_NAME	IN SG_TERM.NAME%TYPE DEFAULT NULL,
		Trm_IDENTIFIER	IN SG_TERM.IDENTIFIER%TYPE DEFAULT NULL,
		Trm_DEFINITION	IN SG_TERM.DEFINITION%TYPE DEFAULT NULL,
		Trm_IS_OBSOLETE	IN SG_TERM.IS_OBSOLETE%TYPE DEFAULT NULL,
		ONT_OID	IN SG_TERM.ONT_OID%TYPE DEFAULT NULL,
		Ont_NAME	IN SG_ONTOLOGY.NAME%TYPE DEFAULT NULL,
		Cache_By_UK	IN INTEGER DEFAULT NULL,
		Cache_By_Id	IN INTEGER DEFAULT NULL,
		do_DML		IN NUMBER DEFAULT BSStd.DML_NO)
RETURN SG_TERM.OID%TYPE
IS
	pk	SG_TERM.OID%TYPE DEFAULT NULL;
	Trm_row Trm_c%ROWTYPE;
	ONT_OID_	SG_ONTOLOGY.OID%TYPE DEFAULT ONT_OID;
	Trm_IDENTIFIER_ SG_TERM.IDENTIFIER%TYPE DEFAULT Trm_IDENTIFIER;
	key_str	VARCHAR2(512) DEFAULT Trm_NAME || '|' || ONT_OID || '|' || ONT_NAME || '|' || Trm_IDENTIFIER;
BEGIN
	-- initialize
	IF (do_DML > BSStd.DML_NO) THEN
		pk := Trm_OID;
	END IF;
	-- look up
	IF pk IS NULL THEN
		IF (key_str = cache_key) THEN
			pk := Trm_cached;
		ELSIF (Trm_IDENTIFIER IS NOT NULL) AND 
		      trm_id_hash.EXISTS(Trm_IDENTIFIER) THEN
			pk := trm_id_hash(Trm_IDENTIFIER);
		ELSIF (key_str IS NOT NULL) AND (Cache_By_UK IS NOT NULL) AND 
		      trm_id_hash.EXISTS(key_str) THEN
			pk := trm_id_hash(key_str);
		ELSE
			-- reset cache
			cache_key := NULL;
			Trm_cached := NULL;
			-- look up SG_ONTOLOGY
			IF (ONT_OID_ IS NULL) THEN
				ONT_OID_ := Ont.get_oid(
					Ont_NAME => Ont_NAME);
			END IF;
			-- do the look up
			IF (Trm_IDENTIFIER IS NOT NULL) THEN
				FOR Trm_row IN Trm_Id_c(Trm_IDENTIFIER) LOOP
		        		pk := Trm_row.OID;
				END LOOP;
			ELSE
				FOR Trm_row IN Trm_c(Trm_NAME, ONT_OID_) LOOP
		        		pk := Trm_row.OID;
					Trm_IDENTIFIER_ := Trm_row.IDENTIFIER;
				END LOOP;
			END IF;
			-- cache if found
			IF (pk IS NOT NULL) THEN
			    	cache_key := key_str;
			    	Trm_cached := pk;
				IF (cache_By_Id IS NOT NULL) AND
				   (Trm_IDENTIFIER_ IS NOT NULL) THEN
					trm_id_hash(Trm_IDENTIFIER_) := pk;
				END IF;
				IF (Cache_By_UK IS NOT NULL) THEN
					trm_id_hash(key_str) := pk;
				END IF;
			END IF;
		END IF;
	END IF;
	-- insert/update if requested
	IF (pk IS NULL) AND 
	   ((do_DML = BSStd.DML_I) OR (do_DML = BSStd.DML_UI)) THEN
	    	-- look up foreign keys if not provided:
		-- look up SG_ONTOLOGY successful?
		IF (ONT_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Ont <' || Ont_NAME || '>');
		END IF;
	    	-- insert the record and obtain the primary key
	    	pk := do_insert(
		        NAME => Trm_NAME,
			IDENTIFIER => Trm_IDENTIFIER,
			DEFINITION => Trm_DEFINITION,
			IS_OBSOLETE => Trm_IS_OBSOLETE,
			ONT_OID => ONT_OID_);
	ELSIF (do_DML = BSStd.DML_U) OR (do_DML = BSStd.DML_UI) THEN
	        -- update the record (note that not provided FKs will not
		-- be changed nor looked up)
		do_update(
			Trm_OID	=> pk,
		        Trm_NAME => Trm_NAME,
			Trm_IDENTIFIER => Trm_IDENTIFIER,
			Trm_DEFINITION => Trm_DEFINITION,
			Trm_IS_OBSOLETE => Trm_IS_OBSOLETE,
			Trm_ONT_OID => ONT_OID_);
	END IF;
	-- return the primary key
	RETURN pk;
END;

FUNCTION get_ont_oid(
		Trm_OID	IN SG_TERM.OID%TYPE)
RETURN SG_ONTOLOGY.OID%TYPE
IS
	opk	SG_ONTOLOGY.OID%TYPE DEFAULT NULL;
BEGIN
	SELECT Ont_Oid INTO opk FROM SG_Term WHERE Oid = Trm_Oid;
	RETURN opk;
END;

FUNCTION do_insert(
		NAME	IN SG_TERM.NAME%TYPE,
		IDENTIFIER	IN SG_TERM.IDENTIFIER%TYPE,
		DEFINITION	IN SG_TERM.DEFINITION%TYPE,
		IS_OBSOLETE	IN SG_TERM.IS_OBSOLETE%TYPE,
		ONT_OID	IN SG_TERM.ONT_OID%TYPE)
RETURN SG_TERM.OID%TYPE 
IS
	pk	SG_TERM.OID%TYPE;
BEGIN
	-- pre-generate the primary key value
	SELECT SG_Sequence.nextval INTO pk FROM DUAL;
	-- insert the record
	INSERT INTO SG_TERM (
		OID,
		NAME,
		IDENTIFIER,
		DEFINITION,
		IS_OBSOLETE,
		ONT_OID)
	VALUES (pk,
		NAME,
		IDENTIFIER,
		DEFINITION,
		IS_OBSOLETE,
		ONT_OID)
	;
	-- return the new pk value
	RETURN pk;
END;

PROCEDURE do_update(
		Trm_OID	IN SG_TERM.OID%TYPE,
		Trm_NAME	IN SG_TERM.NAME%TYPE,
		Trm_IDENTIFIER	IN SG_TERM.IDENTIFIER%TYPE,
		Trm_DEFINITION	IN SG_TERM.DEFINITION%TYPE,
		Trm_IS_OBSOLETE	IN SG_TERM.IS_OBSOLETE%TYPE,
		Trm_ONT_OID	IN SG_TERM.ONT_OID%TYPE)
IS
BEGIN
	-- update the record (and leave attributes passed as NULL untouched)
	UPDATE SG_TERM
	SET
		NAME = NVL(Trm_NAME, NAME),
		IDENTIFIER = NVL(Trm_IDENTIFIER, IDENTIFIER),
		DEFINITION = NVL(Trm_DEFINITION, DEFINITION),
		IS_OBSOLETE = NVL(Trm_IS_OBSOLETE, IS_OBSOLETE),
		ONT_OID = NVL(Trm_ONT_OID, ONT_OID)
	WHERE OID = Trm_OID
	;
END;

END Trm;
/

