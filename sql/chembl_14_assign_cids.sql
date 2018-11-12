ALTER TABLE chembl_14_compound_records ADD COLUMN pubchem_cid INTEGER ;
--
UPDATE
	chembl_14_compound_records
SET
	pubchem_cid=c2b2r_compound."CID"
FROM
	c2b2r_compound,
	chembl_14_compound_structures
WHERE
	gnova.cansmiles(chembl_14_compound_structures.canonical_smiles)=gnova.cansmiles(c2b2r_compound.openeye_can_smiles)
	AND chembl_14_compound_structures.molregno=chembl_14_compound_records.molregno
	;
--
--
--
--
--chord=> \timing
--Timing is on.
--chord=> UPDATE chembl_14_compound_records
--SET
--        pubchem_cid=c2b2r_compound."CID"
--FROM
--        c2b2r_compound,
--        chembl_14_compound_structures
--WHERE
--        gnova.cansmiles(chembl_14_compound_structures.canonical_smiles)=gnova.cansmiles(c2b2r_compound.openeye_can_smiles)
--        AND chembl_14_compound_structures.molregno=chembl_14_compound_records.molregno
--AND chembl_14_compound_records.molregno=2214 ;
--UPDATE 144
--Time: 64235.080 ms
--
--TOO SLOW!
--SO WE PRECOMPUTE gNova cansmiles:
ALTER TABLE chembl_14_compound_structures ADD COLUMN gnova_cansmiles CHARACTER VARYING(4000) ;
UPDATE chembl_14_compound_structures SET gnova_cansmiles=gnova.cansmiles(canonical_smiles) ;
--
-- This error is a major problem:
-- ERROR:  can't make smiles of type 64 from smiles 'CC(C)c1ccc2C=[N+]3N=C(N)[S+]4[Pt]56[S+](C(=N[N+]5=Cc7ccc(c[c-]67)C(C)C)N)[Pt]89[S+](C(=N[N+]8=Cc%10ccc(c[c-]9%10)C(C)C)N)[Pt]%11%12[S+](C(=N[N+]%11=Cc%13ccc(c[c-]%12%13)C(C)C)N)[Pt]34[c-]2c1'
--
-- So it looks like we need to assign CIDs outside of the database and import.
-- This can be done with the PubChem PUG REST API.
