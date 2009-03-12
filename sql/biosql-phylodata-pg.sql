-- $Id$
--
-- Copyright 2009 Hilmar Lapp.
-- 
--  This file is part of BioSQL.
--
--  BioSQL is free software: you can redistribute it and/or modify it
--  under the terms of the GNU Lesser General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  BioSQL is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with BioSQL. If not, see <http://www.gnu.org/licenses/>.
--
-- ========================================================================
--
-- Schema extension on top of the BioSQL core schema for representing
-- phylogenetic data matrices.
--
-- This was developed independently but is very similar to the
-- phylogeny module in Chado (the GMOD common relational model).
--
-- Authors: Hilmar Lapp, hlapp at gmx.net
--
-- comments to biosql - biosql-l@open-bio.org

-- the character matrix
CREATE SEQUENCE charmatrix_pk_seq;
CREATE TABLE charmatrix (
       charmatrix_id INTEGER DEFAULT nextval('charmatrix_pk_seq') NOT NULL,
       name VARCHAR(32) NOT NULL,
       identifier VARCHAR(32),
       biodatabase_id INTEGER NOT NULL,
       type_id INTEGER NOT NULL
       , PRIMARY KEY (charmatrix_id)
       , CONSTRAINT charmatrix_c1 UNIQUE (name, biodatabase_id)
);

COMMENT ON TABLE charmatrix IS 'A character matrix is the collection of characters, OTUs, and character state values that form a unit of analysis.';

COMMENT ON COLUMN charmatrix.name IS 'The name of the character matrix, in essence a label.';

COMMENT ON COLUMN charmatrix.identifier IS 'The identifier of the character matrix, if there is one.';

COMMENT ON COLUMN charmatrix.biodatabase_id IS 'The namespace of the character matrix. If the concept of namespace (often a collection name) encapsulating several matrices does not apply, one may assign a default namespace (such as "biosql"), or create one named the same as the data matrix.';

COMMENT ON COLUMN charmatrix.type_id IS 'The type of the matrix as a link to an ontology term.';

-- qualifier/value pairs (metadata) for character matrices
CREATE TABLE charmatrix_qualifier_value (
       charmatrix_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (charmatrix_id, term_id, rank)
);

COMMENT ON TABLE charmatrix_qualifier_value IS 'Character matrix metadata as attribute/value pairs. Attribute names are from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN charmatrix_qualifier_value.charmatrix_id IS 'The character matrix with which the metadata is being associated.';

COMMENT ON COLUMN charmatrix_qualifier_value.term_id IS 'The name of the metadate element as a term from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN charmatrix_qualifier_value.value IS 'The value of the metadata element.';

COMMENT ON COLUMN charmatrix_qualifier_value.rank IS 'The index of the metadata value if there is more than one value for the same metadata element. If there is only one value, this may be left at the default of zero.';

-- dbxrefs, such as identifiers, for character matrices
CREATE TABLE charmatrix_dbxref (
       charmatrix_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (charmatrix_id, dbxref_id, term_id)
);

CREATE INDEX charmatrix_dbxref_i1 ON charmatrix_dbxref (dbxref_id);

COMMENT ON TABLE charmatrix_dbxref IS 'Secondary identifiers and other database cross-references for character matrices. There can only be one dbxref of a specific type for a character matrix.';

COMMENT ON COLUMN charmatrix_dbxref.charmatrix_id IS 'The character matrix to which the database corss-reference is being assigned.';

COMMENT ON COLUMN charmatrix_dbxref.dbxref_id IS 'The database cross-reference being assigned to the character matrix.';

COMMENT ON COLUMN charmatrix_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a tree accession should be ''primary identifier''.';

-- relating character matrices and trees
CREATE TABLE charmatrix_tree (
       charmatrix_id INTEGER NOT NULL,
       tree_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (charmatrix_id,tree_id,term_id)
);

CREATE INDEX charmatrix_tree_i1 ON charmatrix_tree (tree_id);

-- matrix data characters
CREATE SEQUENCE mchar_pk_seq;
CREATE TABLE mchar (
       mchar_id INTEGER DEFAULT nextval('mchar_pk_seq') NOT NULL,
       label VARCHAR(255),
       description TEXT
       , PRIMARY KEY (mchar_id)
-- CONFIG: you might like to enforce uniqueness of a character's label
-- within a tree, though keep in mind that data providers often
-- violate this constraint 
       --, CONSTRAINT mchar_c1 UNIQUE (label,mchar_id)
);

-- CONFIG: if you decided on the unique key constraint on character
-- label within a matrix, you won't need the index on label, so
-- comment it out for efficiency.
CREATE INDEX mchar_i1 ON mchar (label);

COMMENT ON TABLE mchar IS 'A character in a character data matrix.';

COMMENT ON COLUMN mchar.label IS 'The label of the character.';

-- qualifier/value (metadata) and ontology annotation for data characters
CREATE TABLE mchar_qualifier_value (
       mchar_id INTEGER NOT NULL,       
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mchar_id, term_id, rank)
);

CREATE INDEX mchar_qualifier_value_i1 ON mchar_qualifier_value (term_id);

-- dbxrefs, such as identifiers, for characters of a data matrix
CREATE TABLE mchar_dbxref (
       mchar_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (mchar_id, dbxref_id, term_id)
);

CREATE INDEX mchar_dbxref_i1 ON mchar_dbxref (dbxref_id);

COMMENT ON TABLE mchar_dbxref IS 'Identifiers and other database cross-references for characters of data matrices. There can only be one dbxref of a specific type for a character.';

COMMENT ON COLUMN mchar_dbxref.mchar_id IS 'The character to which the database cross-reference is being assigned.';

COMMENT ON COLUMN mchar_dbxref.dbxref_id IS 'The database cross-reference being assigned to the character.';

COMMENT ON COLUMN mchar_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a node identifier should be ''primary identifier''.';

CREATE SEQUENCE charstate_pk_seq;
CREATE TABLE charstate (
       charstate_id INTEGER DEFAULT nextval('charstate_pk_seq') NOT NULL,
       label VARCHAR(255),
       description TEXT,
       mchar_id INTEGER NOT NULL
       , PRIMARY KEY (charstate_id)
       , CONSTRAINT charstate_c1 UNIQUE (mchar_id,label)
);

CREATE INDEX charstate_id ON charstate (label);

-- qualifier/value (metadata) and ontology annotation for character states
CREATE TABLE charstate_qualifier_value (
       charstate_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , UNIQUE (charstate_id, term_id, rank)
);

CREATE INDEX charstate_qualifier_value_i1 ON charstate_qualifier_value (term_id);

-- dbxrefs, such as identifiers, for character states of a data matrix
CREATE TABLE charstate_dbxref (
       charstate_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (charstate_id, dbxref_id, term_id)
);

CREATE INDEX charstate_dbxref_i1 ON charstate_dbxref (dbxref_id);

-- OTUs (rows of a character data matrix)
CREATE SEQUENCE otu_pk_seq;
CREATE TABLE otu (
       otu_id INTEGER DEFAULT nextval('otu_pk_seq') NOT NULL,
       label VARCHAR(255)
       , PRIMARY KEY (otu_id)
);

COMMENT ON TABLE otu IS 'An OTU is an Operational Taxonomic Unit, the row in a phylogenetic data matrix.';

COMMENT ON COLUMN otu.label IS 'The label (or name) of an OTU.';

-- qualifier/value (metadata) and ontology annotation for OTUs
CREATE TABLE otu_qualifier_value (
       otu_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , UNIQUE (otu_id, term_id, rank)
);

CREATE INDEX otu_qualifier_value_i1 ON otu_qualifier_value (term_id);

-- dbxrefs, such as identifiers, for OTUs of a data matrix
CREATE TABLE otu_dbxref (
       otu_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (otu_id, dbxref_id, term_id)
);

CREATE INDEX otu_dbxref_i1 ON otu_dbxref (dbxref_id);

-- connecting tree nodes and OTUs
CREATE TABLE node_otu (
       node_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (node_id, otu_id, term_id)
);

CREATE INDEX node_otu_i1 ON node_otu (otu_id);

-- associating characters with character matrices (or partitions)
CREATE TABLE charmatrix_mchar (
       charmatrix_id INTEGER NOT NULL,
       mchar_id INTEGER NOT NULL,
       position INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (charmatrix_id,mchar_id,position)
);

CREATE INDEX charmatrix_mchar_i1 ON charmatrix_mchar (mchar_id);

-- associating characters with character matrix partitions
CREATE TABLE charmatrix_otu (
       charmatrix_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       position INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (charmatrix_id,otu_id,position)
);

CREATE INDEX charmatrix_otu_i1 ON charmatrix_otu (otu_id);

-- creating partitions (sub-matrices) of character matrices
CREATE TABLE charmatrix_relationship (
       parent_charmatrix_id INTEGER NOT NULL,
       child_charmatrix_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (parent_charmatrix_id,child_charmatrix_id,term_id)
);

CREATE INDEX charmatrix_relationship_i1 ON charmatrix_relationship (child_charmatrix_id);

-- data matrix cells (also sometimes called 'codings')
CREATE SEQUENCE mcell_pk_seq;
CREATE TABLE mcell (
       mcell_id INTEGER DEFAULT nextval('mcell_pk_seq') NOT NULL,
       mchar_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       charmatrix_id INTEGER NOT NULL
       , PRIMARY KEY (mcell_id)
       , CONSTRAINT mcell_c1 UNIQUE (mchar_id,otu_id,charmatrix_id)
);

CREATE INDEX mcell_i1 ON mcell (otu_id);
CREATE INDEX mcell_i2 ON mcell (charmatrix_id);

-- state values of a data matrix cell
CREATE TABLE mcell_charstate (
       mcell_id INTEGER NOT NULL,
       charstate_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mcell_id,charstate_id,rank)
);

CREATE INDEX mcell_charstate_i1 ON mcell_charstate (charstate_id);

-- qualifier/value (metadata) and ontology annotation for data matrix
-- cells (codings)
CREATE TABLE mcell_qualifier_value (
       mcell_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , UNIQUE (mcell_id, term_id, rank)
);

CREATE INDEX mcell_qualifier_value_i1 ON mcell_qualifier_value (term_id);

-- foreign keys and constraints:

-- table charmatrix:
ALTER TABLE charmatrix ADD CONSTRAINT FKterm_charmatrix
      FOREIGN KEY (type_id) REFERENCES term (term_id);

-- table charmatrix_qualifier_value:
ALTER TABLE charmatrix_qualifier_value ADD CONSTRAINT FKcharmatrix_cmqualvalue
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_qualifier_value ADD CONSTRAINT FKterm_cmqualvalue
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table charmatrix_dbxref
ALTER TABLE charmatrix_dbxref ADD CONSTRAINT FKdbxref_cmdbxref
      FOREIGN KEY (dbxref_id) REFERENCES dbxref (dbxref_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_dbxref ADD CONSTRAINT FKcharmatrix_cmdbxref
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_dbxref ADD CONSTRAINT FKterm_cmdbxref
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table charmatrix_tree
ALTER TABLE charmatrix_tree ADD CONSTRAINT FKterm_cmtree
      FOREIGN KEY (term_id) REFERENCES term (term_id);

ALTER TABLE charmatrix_tree ADD CONSTRAINT FKcharmatrix_cmtree
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id);

ALTER TABLE charmatrix_tree ADD CONSTRAINT FKtree_cmtree
      FOREIGN KEY (tree_id) REFERENCES tree (tree_id);

-- table mchar_qualifier_value:
ALTER TABLE mchar_qualifier_value ADD CONSTRAINT FKterm_mcharqual
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

ALTER TABLE mchar_qualifier_value ADD CONSTRAINT FKmchar_mcharqual
      FOREIGN KEY (mchar_id) REFERENCES mchar (mchar_id)
      ON DELETE CASCADE;

-- table mchar_dbxref:
ALTER TABLE mchar_dbxref ADD CONSTRAINT FKmchar_mchardbxref
      FOREIGN KEY (mchar_id) REFERENCES mchar (mchar_id)
      ON DELETE CASCADE;

ALTER TABLE mchar_dbxref ADD CONSTRAINT FKdbxref_mchardbxref
      FOREIGN KEY (dbxref_id) REFERENCES dbxref (dbxref_id)
      ON DELETE CASCADE;

ALTER TABLE mchar_dbxref ADD CONSTRAINT FKterm_mchardbxref
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table charstate:
ALTER TABLE charstate ADD CONSTRAINT FKmchar_charstate
      FOREIGN KEY (mchar_id) REFERENCES mchar (mchar_id)
      ON DELETE CASCADE;

-- table charstate_qualifier_value:
ALTER TABLE charstate_qualifier_value ADD CONSTRAINT FKcharstate_cstatequalvalue
      FOREIGN KEY (charstate_id) REFERENCES charstate (charstate_id)
      ON DELETE CASCADE;

ALTER TABLE charstate_qualifier_value ADD CONSTRAINT FKterm_cstatequalvalue
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table charstate_dbxref
ALTER TABLE charstate_dbxref ADD CONSTRAINT FKdbxref_cstatedbxref
      FOREIGN KEY (dbxref_id) REFERENCES dbxref (dbxref_id)
      ON DELETE CASCADE;

ALTER TABLE charstate_dbxref ADD CONSTRAINT FKcharstate_cstatedbxref
      FOREIGN KEY (charstate_id) REFERENCES charstate (charstate_id)
      ON DELETE CASCADE;

ALTER TABLE charstate_dbxref ADD CONSTRAINT FKterm_cstatedbxref
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table node_otu:
ALTER TABLE node_otu ADD CONSTRAINT FKotu_nodeotu
      FOREIGN KEY (otu_id) REFERENCES otu (otu_id)
      ON DELETE CASCADE;

ALTER TABLE node_otu ADD CONSTRAINT FKnode_nodeotu
      FOREIGN KEY (node_id) REFERENCES node (node_id)
      ON DELETE CASCADE;

ALTER TABLE node_otu ADD CONSTRAINT FKterm_nodeotu
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;

-- table charmatrix_mchar:
ALTER TABLE charmatrix_mchar ADD CONSTRAINT FKmchar_cmmchar
      FOREIGN KEY (mchar_id) REFERENCES mchar (mchar_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_mchar ADD CONSTRAINT FKcharmatrix_cmmchar
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

-- table charmatrix_otu:
ALTER TABLE charmatrix_otu ADD CONSTRAINT FKotu_cmotu
      FOREIGN KEY (otu_id) REFERENCES otu (otu_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_otu ADD CONSTRAINT FKcharmatrix_cmotu
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

-- table charmatrix_relationship:
ALTER TABLE charmatrix_relationship ADD CONSTRAINT FKparentcharmatrix_cmrel
      FOREIGN KEY (parent_charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_relationship ADD CONSTRAINT FKchildcharmatrix_cmrel
      FOREIGN KEY (child_charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

ALTER TABLE charmatrix_relationship ADD CONSTRAINT FKterm_cmrel
      FOREIGN KEY (term_id) REFERENCES term (term_id);

-- table mcell:
ALTER TABLE mcell ADD CONSTRAINT FKmchar_mcell
      FOREIGN KEY (mchar_id) REFERENCES mchar (mchar_id)
      ON DELETE CASCADE;

ALTER TABLE mcell ADD CONSTRAINT FKotu_mcell
      FOREIGN KEY (otu_id) REFERENCES otu (otu_id)
      ON DELETE CASCADE;

ALTER TABLE mcell ADD CONSTRAINT FKcharmatrix_mcell
      FOREIGN KEY (charmatrix_id) REFERENCES charmatrix (charmatrix_id)
      ON DELETE CASCADE;

-- table mcell_charstate:
ALTER TABLE mcell_charstate ADD CONSTRAINT FKmcell_mcell
      FOREIGN KEY (mcell_id) REFERENCES mcell (mcell_id)
      ON DELETE CASCADE;

ALTER TABLE mcell_charstate ADD CONSTRAINT FKcharstate_mcell
      FOREIGN KEY (charstate_id) REFERENCES charstate (charstate_id)
      ON DELETE CASCADE;

-- table mcell_qualifier_value:
ALTER TABLE mcell_qualifier_value ADD CONSTRAINT FKmcell_mcellqualvalue
      FOREIGN KEY (mcell_id) REFERENCES mcell (mcell_id)
      ON DELETE CASCADE;

ALTER TABLE mcell_qualifier_value ADD CONSTRAINT FKterm_mcellqualvalue
      FOREIGN KEY (term_id) REFERENCES term (term_id)
      ON DELETE CASCADE;
