--
-- SQL script to create the trigger(s) enabling the load API for
-- SGLD_Bioentrys.
--
-- Scaffold auto-generated by gen-api.pl.
--
--
-- $Id: Bioentries.trg,v 1.1.1.1 2002-08-13 19:51:10 lapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Bioentries
       INSTEAD OF INSERT
       ON SGLD_Bioentries
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_BIOENTRY.OID%TYPE DEFAULT :new.Ent_Oid;
	do_DML		INTEGER DEFAULT BSStd.DML_I;
BEGIN
	-- do insert 
	pk := Ent.get_oid(
			Ent_OID => pk,
		        Ent_ACCESSION => :new.Ent_ACCESSION,
			Ent_IDENTIFIER => :new.Ent_IDENTIFIER,
			Ent_NAME => :new.Ent_NAME,
			Ent_DESCRIPTION => :new.Ent_DESCRIPTION,
			Ent_VERSION => :new.Ent_VERSION,
			Ent_DIVISION => :new.Ent_DIVISION,
			Ent_MOLECULE => :new.Ent_MOLECULE,
			DB_OID => :new.DB_OID,
			DB_NAME => :new.DB_NAME,
			DB_ACRONYM => :new.DB_ACRONYM,
			TAX_OID => :new.TAX_OID,
			Tax_NAME => :new.Tax_NAME,
			Tax_NCBI_TAXON_ID => :new.Tax_NCBI_TAXON_ID,
			do_DML             => do_DML);
	-- check whether a sequence length or version was provided, and if
	-- so, create the corresponding Biosequence record
	IF (:new.Ent_Seq_Version IS NOT NULL) OR 
	   (:new.Ent_Seq_Length IS NOT NULL) THEN
	   pk := Seq.get_oid(
			Seq_OID => pk,
			Seq_VERSION => :new.Ent_Seq_Version,
			Seq_LENGTH => :new.Ent_Seq_Length,
			do_DML => do_DML);
	END IF;
END;
/