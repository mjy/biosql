--
-- SQL script to create the trigger(s) enabling the load API for
-- SGLD_Chr_Map_Assocs.
--
-- Scaffold auto-generated by gen-api.pl.
--
--
-- $Id: Chr_Map_Assocs.trg,v 1.1.1.2 2003-01-29 08:54:36 lapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Chr_Map_Assocs
       INSTEAD OF INSERT
       ON SGLD_Chr_Map_Assocs
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_SEQFEATURE.OID%TYPE;
	do_DML		INTEGER DEFAULT BSStd.DML_I;
BEGIN
	-- add the new mapping
	pk := ChrEntA.get_Oid(
			EntSeg_Oid	=> :new.EntSeg_Oid,
			EntSeg_Start_Pos	=> :new.EntSeg_Start_Pos,
			EntSeg_End_Pos	=> :new.EntSeg_End_Pos,
			EntSeg_Num	=> :new.EntSeg_Num,
			ChrSeg_Oid	=> :new.ChrSeg_Oid,
			ChrSeg_Start_Pos	=> :new.ChrSeg_Start_Pos,
			ChrSeg_End_Pos	=> :new.ChrSeg_End_Pos,
			ChrSeg_Strand	=> :new.ChrSeg_Strand,
			ChrSeg_Pct_Identity	=> :new.ChrSeg_Pct_Identity,
			FType_Name	=> :new.FType_Name,
			FSrc_Name	=> :new.FSrc_Name,
			Ent_Oid		=> :new.Ent_Oid,
			Ent_Accession	=> :new.Ent_Accession,
			Ent_Identifier	=> :new.Ent_Identifier,
			Ent_Version	=> :new.Ent_Version,
			DB_Oid		=> :new.DB_Oid,
			DB_Name		=> :new.DB_Name,
			DB_Acronym	=> :new.DB_Acronym,
			Ent_Tax_Oid	=> :new.Ent_Tax_Oid,
			Ent_Tax_Name	=> :new.Ent_Tax_Name,
			Ent_Tax_Variant	=> :new.Ent_Tax_Variant,
			Ent_Tax_NCBI_Taxon_ID	=> :new.Ent_Tax_NCBI_Taxon_ID,
			Chr_Oid		=> :new.Chr_Oid,
			Chr_Name	=> :new.Chr_Name,
			Chr_Accession	=> :new.Chr_Accession,
			Asm_Oid		=> :new.Asm_Oid,
			Asm_Name	=> :new.Asm_Name,
			Asm_Acronym	=> :new.Asm_Acronym,
			Asm_Tax_Oid	=> :new.Asm_Tax_Oid,
			Asm_Tax_Name	=> :new.Asm_Tax_Name,
			Asm_Tax_Variant	=> :new.Asm_Tax_Variant,
			Asm_Tax_NCBI_Taxon_ID	=> :new.Asm_Tax_NCBI_Taxon_ID,
			do_DML		=> do_DML);
END;
/
