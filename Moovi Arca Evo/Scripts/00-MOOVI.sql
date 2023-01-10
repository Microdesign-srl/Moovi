/* 
	-- use ADB_MOOVI
	SCRIPT UPGRADE MOOVI		   
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	VER.		MOOVI	(DB)		
				1.020	(0.0048)
	DEL			17/11/2022
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


	-- ### Da sviluppare

	/\/\/\/\/\/\/\/\/\
	#1		da eseguiri sempre all'inizio dello script
	#1.1		eliminazione delle funzioni
	#1.2		eliminazione delle viste
	#1.2.1		eliminazione delle viste personalizzate

	#1.2.2		eliminazione delle viste utili alle funzioni
	#1.2.2.1	eliminazione delle funzioni utili a viste e funzioni
	#1.2.3		eliminazione delle stored procedure 
	#1.3		eliminazione delle foreign key
	#1.4		eliminazione delle check constraint
	#1.5		eliminazione degli indici
	#1.6		eliminazione dei trigger

	#1.9		Tabella delle configurazioni globali

	#2		inizio scritp con l'avanzamento delle versioni
		
	#0.0032 Versione
	#3		da eseguire sempre al termine dello script
	#3.1		aggiunge i check constraint
	#3.2		aggiunge gli indici
	#3.3		aggiunge le foreign key
	#3.4		gestione delle funzioni 
	#3.4.1		aggiunge le viste necessarie alle funzioni 
	#3.4.2		aggiunge le funzioni 
	#3.5		aggiunge le viste 
	#3.5.1		aggiunge gli indici alle viste
	#3.6		aggiunge i trigger
	#3.7		aggiunge le stored procedure 
	#4		esegue il garant deli oggetti
	#5		aggiorna le viste standard di Arca Evo 
	#6		aggiorna tutte le viste
	#7		mostra della versione finale
	
*/

set ansi_nulls on
set quoted_identifier on 
set ansi_padding on
set nocount on
go

-- drop table xAt_Version
-- gestione di una tabella personalizzata per le versione */
if dbo.afn_du_istable('xMOVersion') = 0 
	exec asp_du_AddTable 'xMOVersion', 0, 'MOOVI versioni'

exec asp_du_addaltercolumn	'xMOVersion', 'DBVer'		, 'int not null'				, ''	, 'Versione'
exec asp_du_addaltercolumn	'xMOVersion', 'DBBuild'		, 'int not null'				, ''	, 'Build'
exec asp_du_addaltercolumn	'xMOVersion', 'DBRevi'		, 'int not null'				, ''	, 'Revisione'
-- la versione completa è versione . build (2) + revisione (2)
-- esempio 1.0354 ---->  1 = versione; 03 = build; 54 = revisione
exec asp_du_dropcolumn		'xMOVersion', 'DBFullVer'
exec asp_du_addaltercolumn	'xMOVersion', 'DBFullVer'	, 'as cast(ltrim(str(DBVer)) + ''.'' + right(''00'' + ltrim(str(DBBuild)), 2) + right(''00'' + ltrim(str(DBRevi)), 2) as numeric(18, 4)) ', ''	, 'Etichetta completa della versione di MOOVI'
exec asp_du_addaltercolumn	'xMOVersion', 'UpdDate'		, 'smalldatetime null'			, ''	, 'Data di aggiornamento versione'
go


if not exists (select DBFullVer from xMOVersion where DBFullVer = 0) begin
	-- crea la versione 0.0
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 0, getdate())
	-- select * from xAt_Version
	print 'Creazione versione iniziale 0.0000'
end
go


-- modifica della FEDI in arca 
-- movimenti interni di magazzino,
-- la gestione delle matricole per aggiungere, editare o elimanare una o più matricole inserite in un record
	
-- -------------------------------------------------------------		
--		#1		da eseguiri sempre all'inizio dello script
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--		#1.1		eliminazione delle funzioni
-- -------------------------------------------------------------
		-- Funzioni generali
exec dbo.asp_du_DropFunction 'xmofn_xMORL_Info'					-- Info sulla testa RL (codice, tipo, utente e terminale)
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_Info_Letture_AR'	-- Info sulle letture e su AR completi e incompleti del prelievo 
exec dbo.asp_du_DropFunction 'xmofn_xMOGiacenza_IN'				
exec dbo.asp_du_DropFunction 'xmofn_xMOGiacenza'
exec dbo.asp_du_DropFunction 'xmofn_xMOCodSpe'		
exec dbo.asp_du_DropFunction 'xmofn_xMOCodSpe_Search'
exec dbo.asp_du_DropFunction 'xmofn_xMOMGEsercizio'
exec dbo.asp_du_DropFunction 'xmofn_xMOIN_Aperti'
exec dbo.asp_du_DropFunction 'xmofn_xMOINRig_AR'				-- Elenco articoli da inventariare
exec dbo.asp_du_DropFunction 'xmofn_DOAperti'					-- Documenti aperti
exec dbo.asp_du_DropFunction 'xmofn_DORistampa'					-- Documenti ristampabili
exec dbo.asp_du_DropFunction 'xmofn_xMOUniLog'
exec dbo.asp_du_DropFunction 'xmofn_xMORLPackListRef'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRigPackingList_AR_GRP'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRigPackingList_AR'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRigPackingList_GetNew'	-- Restituisce l'Unità Logistica (o l'ultima o una nuova)
exec dbo.asp_du_DropFunction 'xmofn_xMORLRigPackingList'		--
exec dbo.asp_du_DropFunction 'xmofn_xMODOSottoCommessa'			-- Elenco delle sottocommesse
exec dbo.asp_du_DropFunction 'xmofn_xMODOSottoCommessa_Std'		-- Elenco delle sottocommesse
exec dbo.asp_du_DropFunction 'xmofn_xMOLinea'					-- Elenco linee di produzione
exec dbo.asp_du_DropFunction 'xmofn_xMOListenerDevice'			-- !! Verificare
exec dbo.asp_du_DropFunction 'xmofn_xMOListener_Moduli'			-- !! Verificare
exec dbo.asp_du_DropFunction 'xmofn_xMOListener'				-- Elenco dei Listener 
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_AR_Std'			-- 
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_AR'				-- RL Righe (elenco delle letture effettuate in rl)
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_Totali'			-- Letture totali con e esenza prelievo di RL Righe 
exec dbo.asp_du_DropFunction 'xmofn_xMOTR_To_Edit'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_P_AR'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_A'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_Totali'			-- Riepilogo per il piede del TR
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_A_AR'
exec dbo.asp_du_DropFunction 'xmofn_CFDest'
exec dbo.asp_du_DropFunction 'xmofn_CF'
exec dbo.asp_du_DropFunction 'xmofn_CF_All'
exec dbo.asp_du_DropFunction 'xmofn_ARMGUbicazione_Giac'
exec dbo.asp_du_DropFunction 'xmofn_MGUbicazioneAR_Giac'
exec dbo.asp_du_DropFunction 'xmofn_MG'
exec dbo.asp_du_DropFunction 'xmofn_MGUbicazione'
exec dbo.asp_du_DropFunction 'xmofn_DOCaricatore'
exec dbo.asp_du_DropFunction 'xmofn_DOBarcode'
exec dbo.asp_du_DropFunction 'xmofn_xMOBarcode'
exec dbo.asp_du_DropFunction 'xmofn_ARARMisura'
exec dbo.asp_du_DropFunction 'xmofn_ARARMisura2'
exec dbo.asp_du_DropFunction 'xmofn_ARLotto'
exec dbo.asp_du_DropFunction 'xmofn_AR'
exec dbo.asp_du_DropFunction 'xmofn_ARValidate'
exec dbo.asp_du_DropFunction 'xmofn_xMORLPrelievo_AR'
exec dbo.asp_du_DropFunction 'xmofn_DOTes_Prel'					-- Prelievo documenti di testa (funzione estesa)
exec dbo.asp_du_DropFunction 'xmofn_DOTes_Prel_Smart'			-- Prelievo documenti di testa (funzione veloce)
exec dbo.asp_du_DropFunction 'xmofn_DO'
exec dbo.asp_du_DropFunction 'xmofn_Get_AR_From_AAA'			-- Converte l'alias o il codice alternativo in Cd_AR 
exec dbo.asp_du_DropFunction 'xmofn_xMORLPrelievo_Test'
exec dbo.asp_du_DropFunction 'xmofn_xMOMGDisp'
exec dbo.asp_du_DropFunction 'xmofn_UbicazioniCorsia_Get'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRDoc4Stoccaggio'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_TA'
exec dbo.asp_du_DropFunction 'xmofn_ARAlias_ARMisura'
exec dbo.asp_du_DropFunction 'xmofn_xMORLPrelievo_NotePiede'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_GetUbicazione'
exec dbo.asp_du_DropFunction 'xmofn_xMORLPrelievo_Azzera'
exec dbo.asp_du_DropFunction 'xmofn_xMOPRBLAttivita'		
exec dbo.asp_du_DropFunction 'xmofn_xMOPRBLMateriali'		
exec dbo.asp_du_DropFunction 'xmofn_xMOPRMPLinea'
exec dbo.asp_du_DropFunction 'xmofn_xMOPRBLMateriali_4BL'
exec dbo.asp_du_DropFunction 'xmofn_xMOPRTR_QtaTrasferita'
exec dbo.asp_du_DropFunction 'xmofn_xMOPRTR_QtaDaTrasferire'

-- DEPRECATE!!
exec dbo.asp_du_DropFunction 'xmofn_xMORL_DoTes'				-- elenco delle rilevazioni che si sono trasformate in doc di Arca
exec dbo.asp_du_DropFunction 'xmofn_AR_AZ'
exec dbo.asp_du_DropFunction 'xmofn_CF_AZ'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_Letture'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig_sumqta'
exec dbo.asp_du_DropFunction 'xmofn_DORig_Prel'
exec dbo.asp_du_DropFunction 'xmofn_sumquantita_P'
exec dbo.asp_du_DropFunction 'xmofn_xMORLRig'					-- Ex per xmofn_xMORLRig_AR
exec dbo.asp_du_DropFunction 'xmofn_Barcode'
exec dbo.asp_du_DropFunction 'xmofn_xMOTRRig_P'
exec dbo.asp_du_DropFunction 'xmofn_xMOSpedizione'				-- deprecata per cambio nome
exec dbo.asp_du_DropFunction 'xmofn_xMOSpedizione_Search'		-- deprecata per cambio nome
exec dbo.asp_du_DropFunction 'xmofn_xMOPRTR_QtaTrasferitaUM1'	-- deprecata per cambio nome

-- -------------------------------------------------------------			
--		#1.2		eliminazione delle viste
-- -------------------------------------------------------------
exec dbo.asp_du_DropView 'xmovs_xMORLRig_ExtFld'
exec dbo.asp_du_DropView 'xmovs_xMOTRRig_A'
exec dbo.asp_du_DropView 'xmovs_xMOTRRig_P'
exec dbo.asp_du_DropView 'xmovs_ARMisura'
exec dbo.asp_du_DropView 'xmovs_CFDest'
exec dbo.asp_du_DropView 'xmovs_CF'
exec dbo.asp_du_DropView 'xmovs_DO'
exec dbo.asp_du_DropView 'xmovs_DOTes'
exec dbo.asp_du_DropView 'xmovs_DORig'
exec dbo.asp_du_DropView 'xmovs_xMORLRig'
exec dbo.asp_du_DropView 'xmovs_xMORL'

-- DEPRECATE
exec dbo.asp_du_DropView 'xmovs_Barcode'
exec dbo.asp_du_DropView 'xmovs_RLRig'
exec dbo.asp_du_DropView 'xmovs_RLRig_Ar'
exec dbo.asp_du_DropView 'xmovs_RLRig_LastAr'
exec dbo.asp_du_DropView 'xmovs_RLPrelievo'
	
go
-- -------------------------------------------------------------
--		#1.2.1		eliminazione delle viste personalizzate
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--		#1.2.2		eliminazione delle viste utili alle funzioni
-- -------------------------------------------------------------
exec dbo.asp_du_DropView 'xmovs_DOOperatore'
exec dbo.asp_du_DropView 'xmovs_DOTerminale'
exec dbo.asp_du_DropView 'xmovs_UniLogTerminale'
exec dbo.asp_du_DropView 'xmovs_UniLogOperatore'
exec dbo.asp_du_DropView 'xmovs_DOxMOControlli'
exec dbo.asp_du_DropView 'xmovs_xMOListenerOperatore'

-- DEPRECATE
exec dbo.asp_du_DropView 'xmovs_ListenerOperatore'
exec dbo.asp_du_DropView 'xmovs_xMOPRTRMateriale'
go
-- ---------------------------------------------------------------------
--		#1.2.2.1	eliminazione delle funzioni utili a viste e funzioni
-- ---------------------------------------------------------------------
-- Funzioni dello stato
exec dbo.asp_du_DropFunction 'xmofn_xMOIN_Stato'
exec dbo.asp_du_DropFunction 'xmofn_xMOTR_Stato'
exec dbo.asp_du_DropFunction 'xmofn_xMORL_Stato'
exec dbo.asp_du_DropFunction 'xmofn_xMOConsumo_Stato'
exec dbo.asp_du_DropFunction 'xmofn_xMOMatricola_Stato'
exec dbo.asp_du_DropFunction 'xmofn_xMOListenerCoda_Stato'
exec dbo.asp_du_DropFunction 'xmofn_Ids_Split'
exec dbo.asp_du_DropFunction 'xmofn_AR_Descrizione' -- Alex
exec dbo.asp_du_DropFunction 'xmofn_StatoGiac'
go
-- -------------------------------------------------------------
--		#1.2.3		eliminazione delle stored procedure
-- -------------------------------------------------------------
--exec asp_du_DropProcedure	'xmosp_LogIn'
exec asp_du_DropProcedure 'xmosp_Login'
exec asp_du_DropProcedure 'xmosp_xMORLLast_Del'
exec asp_du_DropProcedure 'xmosp_xMORLRig_Del'
exec asp_du_DropProcedure 'xmosp_xMORLRig_Save'
exec asp_du_DropProcedure 'xmosp_xMORLPackListRef_Save'
exec asp_du_DropProcedure 'xmosp_xMORLPackListRef_Add'
exec asp_du_DropProcedure 'xmosp_xMORLRig_Controlli'
exec asp_du_DropProcedure 'xmosp_Matricola_Save'
exec asp_du_DropProcedure 'xmosp_ListenerDevice_Add'
exec asp_du_DropProcedure 'xmosp_ListenerCoda_Add'
exec asp_du_DropProcedure 'xmosp_xMORLRigPackList_Shift'
exec asp_du_DropProcedure 'xmosp_xMORLRigPackList_Del'
exec asp_du_DropProcedure 'xmosp_xMORLPrelievo_Save'
exec asp_du_DropProcedure 'xmosp_xMORLPrelievo_Validate'
exec asp_du_DropProcedure 'xmosp_xMORLPiede_Save'
exec asp_du_DropProcedure 'xmosp_xMORLPiede_ChiudiSpedizione'
exec asp_du_DropProcedure 'xmosp_xMORLPrelievo_SaveRL'
exec asp_du_DropProcedure 'xmosp_xMORL_Save'
exec asp_du_DropProcedure 'xmosp_xMORL_Del'
exec asp_du_DropProcedure 'xmosp_xMOTR_Del'
exec asp_du_DropProcedure 'xmosp_IDDR_Validate'
exec asp_du_DropProcedure 'xmosp_Sscc_Validate'
exec asp_du_DropProcedure 'xmosp_DOTes_Prel_ById'
exec asp_du_DropProcedure 'xmosp_xMOConsumoFromRL_Save'
exec asp_du_DropProcedure 'xmosp_xMOConsumo_Save'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_A_Save'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_Save'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_A_Last_Del'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_Last_Del'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_A_Del'	
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_Del'
exec asp_du_DropProcedure 'xmosp_xMOTRPiede_Save'
exec asp_du_DropProcedure 'xmosp_xMOTR_Save'
exec asp_du_DropProcedure 'xmosp_xMOIN_Save'
exec asp_du_DropProcedure 'xmosp_xMOIN_MakeOne_MGMov'
exec asp_du_DropProcedure 'xmosp_xMOIN_Make_MGMov'
exec asp_du_DropProcedure 'xmosp_xMOINRig_AR'
exec asp_du_DropProcedure 'xmosp_xMOINRig_AR_Save'
exec asp_du_DropProcedure 'xmosp_xMOINRig_AR_Add'
exec asp_du_DropProcedure 'xmosp_xMOSpedizione_SaveRL'
exec asp_du_DropProcedure 'xmosp_xMOSpedizione_Close'
exec asp_du_DropProcedure 'xmosp_xMOIN_Delete'
exec asp_du_DropProcedure 'xmosp_DOTes_To_xMORL'
exec asp_du_DropProcedure 'xmosp_ARAlias_Save'
exec asp_du_DropProcedure 'xmosp_xMOMatGiac_Insert_Update'
exec asp_du_DropProcedure 'xmosp_ARCodCF_Save'
exec asp_du_DropProcedure 'xmosp_MGUbicazione_Assegnazione'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_FromMGUBI'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_FromDocs'
exec asp_du_DropProcedure 'xmosp_SMRig_A_Del'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_TA_Save'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_P_AddAR'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_T_RicercaUbicazione'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_T_RicercaUbicazione_Escludi'
exec asp_du_DropProcedure 'xmosp_xMOTRRig_T_Save'
exec asp_du_DropProcedure 'xmosp_xMOPRTR_Save'
exec asp_du_DropProcedure 'xmosp_xMOPRTR_Close'
exec asp_du_DropProcedure 'xmosp_xMOPRTRRig_Save'
exec asp_du_DropProcedure 'xmosp_xMOPRTRRig_Delete'

exec asp_du_DropProcedure 'xmosp_xMOPRTRMateriale_Save'
exec asp_du_DropProcedure 'xmosp_xMOPRTRMateriale_Back'
exec asp_du_DropProcedure 'xmosp_xMOPRTRMateriale_Drop'
exec asp_du_DropProcedure 'xmosp_xMOPRTRMateriale_ToBL'
exec asp_du_DropProcedure 'xmosp_xMOMGUbicazione_Ricerca'

-- DEPRECATE
exec asp_du_DropProcedure 'xmosp_MORLRig_Test'
exec asp_du_DropProcedure 'xmosp_MOTRRig_A_Del'
exec asp_du_DropProcedure 'xmosp_MOTRRig_A_Save'
exec asp_du_DropProcedure 'xmosp_MOTRRig_P_Del'
exec asp_du_DropProcedure 'xmosp_xMORLPrelievo_delete'
exec asp_du_DropProcedure 'xmosp_ListenerCoda_Ins'

go
-- -------------------------------------------------------------
--		#1.3		eliminazione delle foreign key
-- -------------------------------------------------------------
exec asp_du_DropConstraint 'DO'					, 'xFK_DO_CF'
exec asp_du_DropConstraint 'DO'					, 'xFK_DO_CFDest'
exec asp_du_DropCOnstraint 'DO'					, 'xFk_DO_xMOProgramma'
exec asp_du_DropConstraint 'xMODOControllo'		, 'FK_xMODOControllo_DO'
exec asp_du_DropConstraint 'xMODOControllo'		, 'FK_xMODOControllo_xMOControllo'
exec asp_du_DropConstraint 'Operatore'			, 'xFK_Operatore_Mg'	
exec asp_du_DropConstraint 'xMOListenerDevice'	, 'FK_xMOListenerDevice_xMOListener'
exec asp_du_DropConstraint 'xMOListenerCoda'	, 'FK_xMOListenerCoda_xMOListener'
exec asp_du_DropConstraint 'xMOTerminale'		, 'FK_xMOTerminale_xMOListener'
exec asp_du_DropConstraint 'xMOMatricola'		, 'FK_xMOMatricola_xMOLinea'
exec asp_du_DropConstraint 'xMOMatricola'		, 'FK_xMOMatricola_AR'	
exec asp_du_DropConstraint 'xMOMatricola'		, 'FK_xMOMatricola_DORig'
--exec asp_du_DropConstraint 'xMOMatricola'		, 'FK_xMOMatricola_ARLotto'	-- <-- Il lotto deve essere ancora battezzato
exec asp_du_DropConstraint 'xMOConsumo'			, 'FK_xMOConsumo_xMOLinea'
exec asp_du_DropConstraint 'xMOConsumo'			, 'FK_xMOConsumo_AR'	
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_DO'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_Operatore'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_CF'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_CFDest'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_xMOLinea'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_MG_P'					
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_MG_A'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_DoSdTAnag'
exec asp_du_DropConstraint 'xMORL'				, 'FK_xMORL_DOTes'
exec asp_du_DropConstraint 'xMORLPackListRef'	, 'FK_xMORLPackListRef_xMORL'
exec asp_du_DropConstraint 'xMORLPackListRef'	, 'FK_xMORLPackListRef_xMOUniLog'
exec asp_du_DropConstraint 'xMORLPrelievo'		, 'FK_xMORLPrelievo_xMORL'
exec asp_du_DropConstraint 'xMORLPrelievo'		, 'FK_xMORLPrelievo_xMORL'
exec asp_du_DropConstraint 'xMORLRigPackList'	, 'FK_xMORLRigPackList_xMORLRig'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_xMORL'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_AR'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_MG_P'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_xMORL_P'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_MG_A'
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_xMORL_A'				
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_ARLotto'				
exec asp_du_DropConstraint 'xMORLRig'			, 'FK_xMORLRig_ARMisura'			
exec asp_du_DropConstraint 'xMOTR'				, 'FK_xMOTR_MG_A'				
exec asp_du_DropConstraint 'xMOTR'				, 'FK_xMOTR_MGUbicazione_A'				
exec asp_du_DropConstraint 'xMOTR'				, 'FK_xMOTR_MG_P'				
exec asp_du_DropConstraint 'xMOTR'				, 'FK_xMOTR_xMORL_P'				
exec asp_du_DropConstraint 'xMOTR'				, 'FK_xMOTR_Operatore'			
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_xMOTR'			
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_AR'					
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_ARLotto'				
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_ARMisura'			
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_MG_A'				
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_xMORL_A'				
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_MG_P'				
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_xMORL_P'				
exec asp_du_DropConstraint 'xMOTRRig'			, 'Fk_xMOTRRig_MGMovInt'
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_xMOTR'	
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_ARMisura'	
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_MG_A'		
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_xMORL_A'	
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_MGMovInt'	
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_xMOTR'	
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_AR'		
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_ARLotto'	
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_ARMisura'	
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_MG_P'		
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_MGUbicazione_P'	
exec asp_du_DropConstraint 'xMOTRRig_A'			, 'Fk_xMOTRRig_A_xMOTRRig_P'
exec asp_du_DropConstraint 'xMOTRRig_T'			, 'Fk_xMOTRRig_T_xMOTR'			
exec asp_du_DropConstraint 'xMOTRRig_T'			, 'Fk_xMOTRRig_T_MG_A'			
exec asp_du_DropConstraint 'xMOTRRig_T'			, 'Fk_xMOTRRig_T_MGUbicazione_A'
exec asp_du_DropConstraint 'xMOTRRig_T'			, 'Fk_xMOTRRig_T_xMOTRRig_P'
exec asp_du_DropConstraint 'xMOBCCampo'			, 'Fk_xMOBCCampo_Cd_xMOBC'
exec asp_du_DropConstraint 'xMOIN'				, 'FK_xMOIN_Operatore'
exec asp_du_DropConstraint 'xMOIN'				, 'FK_xMOIN_MG'	
exec asp_du_DropConstraint 'xMOIN'				, 'FK_xMOIN_MGUbicazione'	
exec asp_du_DropConstraint 'xMOIN'				, 'FK_xMOIN_MGEsercizio'
exec asp_du_DropConstraint 'xMOINRig'			, 'FK_xMOINRig_xMOIN'	
exec asp_du_DropConstraint 'xMOINRig'			, 'FK_xMOINRig_Cd_AR'	
exec asp_du_DropConstraint 'xMOINRig'			, 'Fk_xMOINRig_ARMisura'
exec asp_du_DropConstraint 'xMOINRig'			, 'Fk_xMOINRig_DOSottoCommessa'				
exec asp_du_DropConstraint 'xMOINRig'			, 'Fk_xMOINRig_ARLotto'	
exec asp_du_DropConstraint 'xMOINRig'			, 'FK_xMOINRig_MG'	
exec asp_du_DropConstraint 'xMOINRig'			, 'FK_xMOINRig_MGUbicazione'
exec asp_du_DropConstraint 'xMOMGCorsia'		, 'FK_xMOMGCorsia_MG'
exec asp_du_DropConstraint 'MGUbicazione'		, 'xFK_MGUbicazione_xMOMGCorsia'
exec asp_du_DropConstraint 'xMOPRTR'			, 'FK_xMOPRTR_Operatore'
exec asp_du_DropConstraint 'xMOPRTR'			, 'FK_xMOPRTR_PRTRAttivita'
exec asp_du_DropConstraint 'xMOPRTRRig'			, 'FK_xMOPRTRRig_xMOPRTR'
exec asp_du_DropConstraint 'xMOPRTRRig'			, 'FK_xMOPRTRRig_Cd_AR'			
exec asp_du_DropConstraint 'xMOPRTRRig'			, 'Fk_xMOPRTRRig_ARMisura'
exec asp_du_DropConstraint 'xMOPRTRRig'			, 'Fk_xMOPRTRRig_ARLotto'			

--deprecate!
exec asp_du_DropConstraint 'xMORLPrelievo'		, 'FK_xMORLPrelievo_DOTes'
exec asp_du_DropConstraint 'xMORLPrelievo'		, 'FK_xMORLPrelievo_DORig'
exec asp_du_DropConstraint 'xMOTRRig_P'			, 'Fk_xMOTRRig_P_xMORL_P'	

go
-- -------------------------------------------------------------
--		#1.4		eliminazione delle check constraint
-- -------------------------------------------------------------
exec asp_du_DropConstraint 'xMOINRig'           , 'CK_xMOINRig_QtaRilevata'    
exec asp_du_DropConstraint 'DO'					, 'xCK_DO_xMOResiduoInPrelievo'
exec asp_du_DropConstraint 'DO'					, 'xCK_DO_TipoDocumento'
exec asp_du_DropConstraint 'MGUbicazione'		, 'xCK_MGUbicazione_xMOStato'
exec asp_du_DropConstraint 'MGUbicazione'		, 'xCK_MGUbicazione_xMOTipo'
exec asp_du_DropConstraint 'MGUbicazione'		, 'xCK_MGUbicazione_AssegnazioneACorsia'
--exec asp_du_DropConstraint 'DO'					, 'xCK_DO_TipoDocumento'

go
-- -------------------------------------------------------------
--		#1.5		eliminazione degli indici
-- -------------------------------------------------------------
exec asp_du_DropIndex 'xMOTerminale'			, 'UK_xMOTerminale_Terminale'
exec asp_du_DropIndex 'xMORLPrelievo'			, 'UK_xMORLPrelievo_Id_xMORL_Id_DOTes_Id_DORig'
exec asp_du_DropIndex 'xMOListener'				, 'UK_xMOListener_IP_ListenPort_Attivo'
exec asp_du_DropIndex 'xMOMatGiac'				, 'UK_xMOMatGiac_Matricola_Cd_Ar_Cd_ArLotto'

-- DEPRECATO
exec asp_du_DropIndex 'xMOListener'				, 'UK_xMOListener_IP_Attivo'

go

-- -------------------------------------------------------------
--		#1.6		eliminazione dei trigger
-- -------------------------------------------------------------
exec asp_du_DropTrigger		'crea_lotto'
exec asp_du_DropTrigger		'xMO_DORig_xMOMatricola_Disponibile'

go
-- -------------------------------------------------------------		
--		#1.9		Tabella delle configurazioni globali
-- -------------------------------------------------------------

if dbo.afn_du_IsTable('xMOImpostazioni') = 0
	exec asp_du_AddTable 'xMOImpostazioni', 0, 'Impostazioni per MOOVI'

exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'LogInTerminale'		, 'bit not null'			, '1'			, 'Se attivo verifica che l''IP del terminale sia presente tra quelli attivi'
-- Movimenti interni
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovIntDescrizione'	, 'varchar(30) null'		, ''			, 'Descrizione di default dei TRASFERIMENTI interni'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovIntAbilita'		, 'bit not null'			, '1'			, 'Attiva/Disattiva la gestione dei TRASFERIMENTI interni'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovIntUbicazione'	, 'bit not null'			, '0'			, 'Attiva/Disattiva la gestione dell''ubicazione per i TRASFERIMENTI interni'
-- ### Inserire un campo per la valorizzazione dei movimenti interni (like cmd_mgmovint.vcx) tipo: "Ultimo", "FIFO", "LIFO", Ecc...
-- Matricola
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatSchedule'			, 'int not null'			, '0'			, 'Se maggiore di zero è il tempo in secondi per l''import dei documenti di carico'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatCd_xMOListener'	, 'varchar(64) null'		, ''			, 'Listener che effettua i carichi delle matricole per la produzione (un solo Listener può effettuare questa operazione)'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatCd_DO'			, 'char(3) null'			, ''			, 'Codice documento da generare per le matricole prodotte sulla linea'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatCd_CF'			, 'char(7) null'			, ''			, 'Codice fornitore per la generazione del documento per le matricole prodotte sulla linea'
exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatCd_ARMisura'		, 'char(2) null'			, ''			, 'Unita di misura del articolo per l''import dei carichi di produzione'

go
-- -------------------------------------------------------------		
--		#2		inizio scritp con l'avanzamento delle versioni
-- -------------------------------------------------------------

	-- -------------------------------------------------------------
	-- #0.0001 Versione 
	-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0000 begin

	print '0.0001 inizio script'

	-- Inserisco l'impostazione di default
	exec ('if not exists(select * from xMOImpostazioni) insert into xMOImpostazioni (MovIntDescrizione, LogInTerminale) values (''Movimento interno'', 1) ')

	-- Tabella dei cicli del documento di MOOVI
	
	if dbo.afn_du_IsTable('xMOControllo') = 0
		exec asp_du_AddTable 'xMOControllo', 20,'Controlli attivi per MOOVI'

	exec asp_du_AddAlterColumn 'xMOControllo'		, 'Descrizione'			, 'varchar(50) not null'		, ''			, 'Descrzione del ciclo attivo'
	exec asp_du_AddAlterColumn 'xMOControllo'		, 'TipoControllo'		, 'varchar(20) not null'		, ''			, 'Tipo di controllo effettuato'
	exec asp_du_AddAlterColumn 'xMOControllo'		, 'Attivo'				, 'bit not null'				, '0'			, 'attivo tipo di controllo'

	
	
	-- Aggiungo i parametri di moovi alla parametrizzazione dei documenti
	--xMOCd_CF, xMOCd_CFDest
	exec asp_du_addaltercolumn 'DO'					, 'xMOAttivo'				, 'bit not null'			, '0'		, 'Il documento è attivo'
	exec asp_du_addaltercolumn 'DO'					, 'xMOCd_CF'				, 'char(7) null'			, ''		, 'Il codice del cliente/fornitore'
	exec asp_du_addaltercolumn 'DO'					, 'xMOCd_CFDest'			, 'char(3) null'			, ''		, 'Il codice del destinazione'
	exec asp_du_addaltercolumn 'DO'					, 'xMOPrelievo'				, 'bit not null'			, '0'		, 'Prelievo effettuato'
	exec asp_du_addaltercolumn 'DO'					, 'xMOPrelievoObb'			, 'bit not null'			, '0'		, 'Prelievo obbligatorio effettuato'
	exec asp_du_addaltercolumn 'DO'					, 'xMOFuoriLista'			, 'bit not null'			, '0'		, 'Fuori lista'
	exec asp_du_addaltercolumn 'DO'					, 'xMOUmDef'				, 'smallint not null'		, '0'		, 'Unità di misura di default (0 = Principale; 1 = La prima secondaria; 2 = La seconda secondaria; n = La ennesima secondaria)'
	exec asp_du_addaltercolumn 'DO'					, 'xMOLinea'				, 'bit not null'			, '0' 		, 'Richiesta di linea'
	exec asp_du_addaltercolumn 'DO'					, 'xMOLotto'				, 'bit not null'			, '0' 		, 'Presenza di lotto'
	exec asp_du_addaltercolumn 'DO'					, 'xMOUbicazione'			, 'bit not null'			, '0' 		, 'Ubicato o meno IL documento'
	exec asp_du_addaltercolumn 'DO'					, 'xMOControlli'			, 'bit not null'			, '0' 		, 'Controlli per-conferma attivi'
	exec asp_du_addaltercolumn 'DO'					, 'xMOTarga'				, 'bit not null'			, '0' 		, 'Vero se il campo Targa è visibile nel documento (se presente è obbligatorio inserirlo)'
	exec asp_du_addaltercolumn 'DO'					, 'xMODatiPiede'			, 'bit not null'			, '0' 		, 'Attiva la compilazione dei dati del piede del documento'
	exec asp_du_addaltercolumn 'DO'					, 'xMOQuantitaDef'			, 'smallint not null'		, '0' 		, 'Proponi quantita articolo (0 = nessuno; 1 = 1 unita ; 2 = Totale prelevabile;)'
	exec asp_du_addaltercolumn 'DO'					, 'xMOBarcode'				, 'xml null'				, '' 		, 'XML dei barcode attivi per il documento (rows/row codice, attivo, posizione es.: <rows><row codice="GS1" attivo="1" posizione="1" /><row codice="SSCC" attivo="1" posizione="2" /><row codice="SSCC_NEW" attivo="1" posizione="2" /></rows>)'
	exec asp_du_addaltercolumn 'DO'					, 'xMOTerminali'			, 'xml null'				, '' 		, 'Se nullo il documento viene gestito da tutti i terminali di MOOVI; Se specificato uno o più codici terminale il documento sarà gestito solo da quelli indicati'
	exec asp_du_AddAlterColumn 'DO'					, 'xMOOperatori'			, 'xml null'				, ''		, 'Se nullo il documento viene gestito da tutti i operatori di MOOVI; Se specificato uno o più codici operatori il documento sarà gestito solo da quelli indicati (ha prevalenza su xMOTerminali)'

	-- Aggiunge i campi personalizzati per MOOVI nei documenti
	exec asp_du_addaltercolumn 'DOTes'				, 'xCd_xMOLinea'			, 'varchar(20) null'		, '' 		, 'Linea di MOOVI'
	exec asp_du_AddAlterColumn 'DOTes'				, 'xTarga'					, 'varchar(20) null'		, ''		, 'Targa di MOOVI'

	-- Aggiunge l'unità di misura standard per MOOVI
	exec asp_du_AddAlterColumn 'ARMisura'			, 'xMODefault'				, 'bit not null'			, '0'		, 'Unità di misura di default per Moovi'

	-- Tabella configurazione controlli per documento
	if dbo.afn_du_IsTable('xMODOControllo') = 0
		exec asp_du_AddTable 'xMODOControllo', 0,'Configurazione controlli dei documenti per MOOVI ' 
	
	exec asp_du_AddAlterColumn 'xMODOControllo'		, 'Cd_DO'					, 'char(3) not null'		, ''		, ''
	exec asp_du_AddAlterColumn 'xMODOControllo'		, 'Cd_xMOControllo'			, 'varchar(20) not null'	, ''		, ''


	-- Tabella degli operatori di MOOVI
	exec asp_du_addaltercolumn 'Operatore'			, 'xMOAttivo'				, 'bit not null'			, '0'		, 'attivo operatore'
	exec asp_du_addaltercolumn 'Operatore'			, 'xMOCd_MG'				, 'char(5) null'			, ''		, 'magazzino di riferimento per MOOVI'
	
		
	-- Tabella dei terminali di MOOVI
	if dbo.afn_du_istable('xMOTerminale')=0
		exec asp_du_AddTable 'xMOTerminale', 0, 'Configurazione Terminali di MOOVI (il campo UK Terminale è l''IP e non può essere duplicato'
	
	exec asp_du_addaltercolumn 'xMOTerminale'		, 'Terminale'				, 'varchar(39) not null'	, ''		, 'Indirizzo IP V4 o IP V6 del terminale'
	exec asp_du_addaltercolumn 'xMOTerminale'		, 'Descrizione'				, 'varchar(50) not null'	, ''		, 'Descrizione del terminale'
	exec asp_du_addaltercolumn 'xMOTerminale'		, 'Attivo'					, 'bit not null'			, '0'		, 'Terminale attivo'		
	exec asp_du_AddAlterColumn 'xMOTerminale'		, 'MovIntAbilita'			, 'bit not null'			, '1'		, 'Attiva/Disattiva la gestione dei TRASFERIMENTI interni'
	exec asp_du_AddAlterColumn 'xMOTerminale'		, 'MovIntUbicazione'		, 'bit not null'			, '0'		, 'Attiva/Disattiva la gestione dell''ubicazione per i movimenti interni'
	exec asp_du_AddAlterColumn 'xMOTerminale'		, 'Cd_xMOListener'			, 'varchar(64) null'		, ''		, 'Listener associato al terminale'
	
	-- Tabella dei terminali di MOOVI
	-- drop table xMOListener
	if dbo.afn_du_istable('xMOListener')=0
		exec asp_du_AddTable 'xMOListener', 64, 'Elenco Listener configurati in azienda per la creazione/stampa dei documenti di Moovi'
	
	exec asp_du_addaltercolumn 'xMOListener'			, 'Descrizione'			, 'varchar(50) null'		, ''		, 'Descrizione del Listener'
	exec asp_du_addaltercolumn 'xMOListener'			, 'IP'					, 'varchar(39) null'		, ''		, 'Indirizzo Ip del Listener'
	exec asp_du_addaltercolumn 'xMOListener'			, 'ListenPort'			, 'int null'				, ''		, 'Indirizzo socket del Listener'
	exec asp_du_addaltercolumn 'xMOListener'			, 'ReplayPort'			, 'int null'				, ''		, 'Indirizzo socket di risposta del Listener al terminale'
	exec asp_du_addaltercolumn 'xMOListener'			, 'Attivo'				, 'bit not null'			, '1'		, 'Il Listener è Attivo'


	-- Creazione tabella delle code delle richieste di generazione/stampa documenti
	IF dbo.afn_du_IsTable('xMOListenerCoda')  = 0
		exec asp_du_AddTable 'xMOListenerCoda', 0, 'MOOVI - Coda di lettura per il Listener'

	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Cd_xMOListener'		, 'varchar(64) not null'	, ''		, 'Codice del Listener'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Terminale'			, 'varchar(39) not null'	, ''		, 'IP del terminale che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Cd_Operatore'		, 'varchar(20) not null'	, ''		, 'Operatore che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'DataOra'				, 'smalldatetime not null'	,''			, 'Data Ora di arrivo della richiesta'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Comando'				, 'varchar(max) not null'	,''			, 'Comando passato al Listener'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Stato'				, 'smallint not null'		,'0'		, 'Stato del comando della coda (vedere xmofn_xMOListenerCoda_Stato)'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'		, 'Esito'				, 'varchar(max)'			,''			, 'Esito testuale esecuzione comando'

	-- Creazione tabella delle code delle richieste di generazione/stampa documenti
	IF dbo.afn_du_IsTable('xMOListenerDevice')  = 0
		exec asp_du_AddTable 'xMOListenerDevice', 0, 'MOOVI - Device di stampa'

	exec asp_du_AddAlterColumn 'xMOListenerDevice'		, 'Cd_xMOListener'		, 'varchar(64) not null'	, ''		, 'Codice del Listener'
	exec asp_du_AddAlterColumn 'xMOListenerDevice'		, 'Device'				, 'varchar(220) not null'	, ''		, 'Codice del Device di stampa'

	--Tabelle delle linea produttiva

	if dbo.afn_du_IsTable ('xMOLinea') = 0
		exec asp_du_AddTable 'xMOLinea', 20, 'Linea produttiva'

	exec asp_du_AddAlterColumn 'xMOLinea'			, 'Descrizione'			, 'varchar(50) not null'		, ''		, 'Descrizione della line produttiva per MOOVI'
	exec asp_du_AddAlterColumn 'xMOLinea'			, 'Cd_MG'				, 'char(5) not null'			, ''		, 'Magazzino di lavoro della linea (Le giacenze dei Consumi vengono calcolate in questo magazzino)'
	
	--Tabelle Matricole di MOOVI (Matriola = SSCC)
	if dbo.afn_du_IsTable ('xMOMatricola') = 0
		exec asp_du_AddTable'xMOMatricola', 80,  'Matricola generata dalla linea di produzione (SSCC)'
	 
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'DataOra'				, 'datetime not null'			, ''		, 'Data e ora della matricola'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Cd_xMOLinea'			, 'varchar(20) not null'		, ''		, 'Codice linea'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Articolo di riferimento per MOOVI'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Cd_ARLotto'			, 'varchar(20) not null'		, ''		, 'Lotto del prodotto'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Stato'				, 'smallint not null'			, '0'		, 'Stato della matricola (vedere xmofn_xMOMatricola_Stato)'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Messaggio'			, 'varchar(max) null'			, ''		, 'Messaggio dello stato'
	exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Id_DORig'			, 'int null'					, ''		, 'Id documento di carico di produzione'
	-- Generati direttamente dalla procedura di creazione carichi
	--exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Cd_ARMisura'			, 'char(2) null'				, ''		, '[Calcolato dal Trigger] Unita di misura del articolo'
	--exec asp_du_AddAlterColumn 'xMOMatricola'		, 'FattoreToUM1'		, 'numeric(18,8) null'			, ''		, '[Calcolato dal Trigger] Fattore di conversione rispetto all''unità di misura principale'
	--exec asp_du_AddAlterColumn 'xMOMatricola'		, 'Quantita'			, 'numeric(18,8) null'			, ''		, '[Calcolato dal Trigger] Quantita'

	--Tabella Consumo di MOOVI
	if dbo.afn_du_IsTable ('xMOConsumo') = 0
		exec asp_du_AddTable'xMOConsumo', 0,  'Definizione dei consumi dei lotti dalla linea di produzione'
	 
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha creato il documento'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Utente che ha creato il documento'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'DataOra'				, 'datetime not null'			, ''		, 'Data e ora dell''inizio del consumo del materiale'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Cd_xMOLinea'			, 'varchar(20) not null'		, ''		, 'Codice linea'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Articolo di inizio consumo'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Cd_ARLotto'			, 'varchar(20) not null'		, ''		, 'Lotto del prodotto consumato'
	exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Stato'				, 'smallint not null'			, '0'		, 'Stato del consumo (vedere xmofn_xMOConsumo_Stato)'
	--exec asp_du_AddAlterColumn 'xMOConsumo'			, 'Id_DoRig'			, 'int null'					, ''		, 'Id documento di carico di produzione che ha scaricato il componente'

	-- tabella delle Rilevazioni di testa per MOOVI
	if dbo.afn_du_IsTable('xMORL') = 0
		exec asp_du_AddTable 'xMORL', 0, 'Documenti generato dall''operatore di MOOVI'

	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_DO'				, 'char(3) not null'			, ''		, 'Documento'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha creato il documento'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Utente che ha creato il documento'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Stato'				, 'smallint not null'			, '0'		, 'Stato della rilevazione (vedere xmofn_xMORL_Stato)'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Id_DOTes'			, 'int null'					, ''		, 'Identificativo del documento di Arca generato (Sato = 1)'
	exec asp_du_addaltercolumn 'xMORL'				, 'Cd_CF'				, 'char(7) not null'			, ''		, 'Codice del cliente/fornitore'
	exec asp_du_addaltercolumn 'xMORL'				, 'Cd_CFDest'			, 'char(3) null'				, ''		, 'il codice del destinazione'
	exec asp_du_AddAlterColumn 'xMORL'				, 'DataDoc'				, 'smalldatetime not null'		, ''		, 'data creazione della rilevazione'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_xMOLinea'			, 'varchar(20) null'			, ''		, 'la linea produttiva di cui si occupa utente'
	exec asp_du_AddAlterColumn 'xMORL'				, 'NumeroDocRif'		, 'varchar(20) null'			, ''		, 'Numero del documento del Cliente/Fornitore'
	exec asp_du_AddAlterColumn 'xMORL'				, 'DataDocRif'			, 'smalldatetime null'			, ''		, 'Data del documento del Cliente/Fornitore'
	exec asp_du_AddAlterColumn 'xMORL'				, 'NotePiede'			, 'varchar(max) null'			, ''		, 'Note del piede'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_MG_P'				, 'char(5) null'				, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_MG_A'				, 'char(5) null'				, ''		, 'Codice del Magazzino di arrivo'
	exec asp_du_AddAlterColumn 'xMORL'				, 'Targa'				, 'varchar(20) null'			, ''		, 'Targa del mezzo di trasporto'
	
	-- tabella Prelievo di MOOVI
	if dbo.afn_du_IsTable ('xMORLPrelievo') = 0
		exec asp_du_AddTable 'xMORLPrelievo', 0, 'Prelievo collegato al documento di testa in MOOVI'
	
	exec asp_du_AddAlterColumn 'xMORLPrelievo'		, 'Id_xMORL'			, 'int not null'				, ''		, 'Identificativo del documento di testa di MOOVI'
	exec asp_du_AddAlterColumn 'xMORLPrelievo'		, 'Id_DOTes'			, 'int not null'				, ''		, 'Identificativo del documento di testa di Arca'
	exec asp_du_AddAlterColumn 'xMORLPrelievo'		, 'Id_DORig'			, 'int not null'				, ''		, 'Identificativo del documento di riga di Arca'
	--exec asp_du_AddAlterColumn 'xMORLPrelievo'		, 'Descrizione'			, 'varchar(50) null'			, ''		, 'A prelievo eseguito contiene nome documento/data e cliente'	--- /
		
	-- tabella DORig di MOOVI
	if dbo.afn_du_IsTable ('xMORLRig') = 0
		exec asp_du_AddTable 'xMORLRig', 0, 'Letture degli articoli inseriti nelle rilevazioni di testa (per documento) in MOOVI'
	
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Id_xMORL'			, 'int not null'				, ''		, 'Identificativo del documento di testa di MOOVI'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Identificativo del documento di testa di MOOVI'
	--exec asp_du_AddAlterColumn 'xMORLRig'			, 'Descrizione'			, 'varchar(50) not null'		, ''		, ''
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_MG_P'				, 'char(5) null'				, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_MGUbicazione_P'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_MG_A'				, 'char(5) null'				, ''		, 'Codice del Magazzino di arrivo'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_MGUbicazione_A'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di arrivo'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_ARLotto'			, 'varchar(20) null'			, ''		, 'Lotto del prodotto'
	-- Data validità/scadenza della lettura (utile per la generazione del Lotto in Arca aggiunto nella ver 0.15)
	exec asp_du_addaltercolumn 'xMORLRig'			, 'DataScadenza'		, 'smalldatetime null'			, ''		, 'Data validità del lotto'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Matricola'			, 'varchar(80) null'			, ''		, 'Matricola'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_ARMisura'			, 'char(2) not null'			, ''		, 'unita di misura del articolo'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'FattoreToUM1'		, 'numeric(18,8) not null'		, '1'		, 'Fattore di conversione rispetto all''unità di misura principale'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Quantita'			, 'numeric(18,8) not null'		, ''		, 'Quantita'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'DataOra'				, 'smalldatetime not null'		, '(getdate())', 'Data e ora della lettura'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Barcode'				, 'xml null'					, ''		, 'Codici barcode letti nella rilevazione (rows/row codice e valore es.: <rows><row codice="GS1" valore="3499ABBB76494994" /><row codice="SSCC" valore="3437843348990480934803489340" /></rows>)'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha creato la riga del documento'
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Utente che ha creato la riga del documento'

	-- Tabella di righe dei TRASFERIMENTI interni
	if dbo.afn_du_IsTable ('xMOTR') = 0
		exec asp_du_AddTable 'xMOTR', 0, 'Teste per il trasferimento interno '
	
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Operatore che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Descrizione'			, 'varchar(30) not null'		, ''		, 'Descrizione della movimentazione'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'DataMov'				, 'smalldatetime not null'		, ''		, 'data creazione della rilevazione'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Stato'				, 'smallint not null'			, '0'		, 'Stato del trasferimento (vedere xmofn_xMOTR_Stato)'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Cd_MG_P'				, 'char(5) null'				, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Cd_MGUbicazione_P'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Cd_MG_A'				, 'char(5) null'				, ''		, 'Codice del Magazzino di arrivo'
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Cd_MGUbicazione_A'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di arrivo'


	-- Tabella di righe dei TRASFERIMENTI interni di PARTENZA 
	if dbo.afn_du_IsTable ('xMOTRRig_P') = 0
		exec asp_du_AddTable 'xMOTRRig_P', 0, 'Articoli inseriti nelle rilevazioni per il trasferimento interno'

	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Id_xMOTR'			, 'int not null'				, ''		, 'Identificativo della rilevazione di trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Operatore che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Codice articolo di riferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_ARLotto'			, 'varchar(20) null'			, ''		, 'Lotto del prodotto'	
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_ARMisura'			, 'char(2) not null'			, ''		, 'Unità di misura'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'FattoreToUM1'		, 'numeric(18,8) not null'		, '1'		, 'Fattore di conversione rispetto all''unità di misura principale'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Quantita'			, 'numeric(18,8) not null'		, ''		, 'Quantita'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'DataOra'				, 'smalldatetime not null'		, '(getdate())', 'Data e ora della lettura'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_MG_P'				, 'char(5) not null'			, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Cd_MGUbicazione_P'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'

	
	-- Tabella di righe dei TRASFERIMENTI interni di ARRIVO
	if dbo.afn_du_IsTable ('xMOTRRig_A') = 0
		exec asp_du_AddTable 'xMOTRRig_A', 0, 'Articoli inseriti nelle rilevazioni per il trasferimento interno'
	
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Id_xMOTR'			, 'int not null'				, ''		, 'Identificativo della rilevazione di trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Terminale'			, 'varchar(39) not null'		, ''		, 'IP del terminale che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Operatore che ha effettuato il trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Id_xMOTRRig_P'		, 'int not null'				, ''		, 'Identificativo univoco del movimento di trasferimento di partenza'
	--exec asp_du_AddAlterColumn 'xMOTRRig'			, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Codice articolo di riferimento'
	--exec asp_du_AddAlterColumn 'xMOTRRig'			, 'Cd_ARLotto'			, 'varchar(20) null'			, ''		, 'Lotto del prodotto'	
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Cd_ARMisura'			, 'char(2) not null'			, ''		, 'Unità di misura'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'FattoreToUM1'		, 'numeric(18,8) not null'		, '1'		, 'Fattore di conversione rispetto all''unità di misura principale'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Quantita'			, 'numeric(18,8) not null'		, ''		, 'Quantita'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'DataOra'				, 'smalldatetime not null'		, '(getdate())', 'Data e ora della lettura'
	--exec asp_du_AddAlterColumn 'xMOTRRig'			, 'Cd_MG_P'				, 'char(5) not null'			, ''		, 'Codice del Magazzino di partenza'
	--exec asp_du_AddAlterColumn 'xMOTRRig'			, 'Cd_MGUbicazione_P'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Cd_MG_A'				, 'char(5) null'				, ''		, 'Codice del Magazzino di arrivo (nullo per consentire all''operatore di specificare successivamente alle letture il magazzino di arrivo)'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Cd_MGUbicazione_A'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di arrivo'
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Id_MGMovInt'			, 'int null'					, ''		, 'Identificativo del movimento interno in Arca'
	-- NON LO STORICIZZIAMO exec asp_du_AddAlterColumn 'xMOTRMGTes'			, 'Cd_xMOMatricola'		, 'varchar(80) null'			, ''		, 'SSCC di riferimento per l''articolo'


	
	-- tabella della codifica dei barcode 
	if dbo.afn_du_IsTable('xMOBC') = 0
		exec asp_du_AddTable 'xMOBC', 10, 'Elenco codici barcode definiti'
	
	exec asp_du_AddAlterColumn 'xMOBC'			, 'Tipo'				, 'int not null'				, ''		, 'Tipo di codifica del barcode (fisso: 1 = GS1; 2 = SSCC; 3 = Barcode strutturato) '
	exec asp_du_AddAlterColumn 'xMOBC'			, 'Descrizione'			, 'varchar(50) not null'		, ''		, 'nome dell''azienda che ha quella tipologia'
	-- ### Da sviluppare
	-- exec asp_du_AddAlterColumn 'xMOBC'			, 'NParti'				, 'int not null'				, '1'		, 'Numero di letture da eseguire per completare il barcode (esistono barcode stampati su più linee)'

	-- lista delle tipologia di codifica dei barcode
	if dbo.afn_du_IsTable('xMOBCCampo') = 0
		exec asp_du_AddTable 'xMOBCCampo', 0, 'Campi definiti per i barcode'
	
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'Cd_xMOBC'			, 'char(10) not null'			, ''		, 'Tipo di codifica del barcode (gs1, barcode personalizzato)'
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'Ordine'				, 'int not null'				, ''		, 'Indice di posizione nel barcode'
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'Codice'				, 'char(4) not null'			, ''		, 'Codice del barcode'
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'LunghezzaMin'		, 'int not null'				, ''		, 'Lunghezza minima del campo da leggere (se lunghezza fissa il valore è uguale alla lunghezzaMax)'
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'LunghezzaMax'		, 'int not null'				, ''		, 'Lunghezza massima del campo da leggere (se lunghezza fissa il valore è uguale alla lunghezzaMin)'
	exec asp_du_AddAlterColumn 'xMOBCCampo'		, 'CampoDb'				, 'varchar(50) null'			, ''		, 'Codice campo del database (es.: codice articolo = Cd_AR, codice lotto Cd_ARLotto, ecc...). Se NULLO il barcode viene interpretato ma non assegnato in un campo del database.'
	/*
		-- ### Da sviluppare
		Potrebbe essere necessario codificare una maschera per l'interpretazione del BC
		Tipo per la data: GG/MM/AA o YYYY/DD/MM
	*/

	--if dbo.afn_du_istable('xReparto') = 0 
	--	exec asp_du_addtable 'xReparto', 20, 'Anagrafica dei Reparti'

	--exec asp_du_addaltercolumn	'xReparto',	'Descrizione'	, 'varchar(30) not null', '', 'Descrizione del reparto'
	--exec asp_du_addaltercolumn	'xReparto',	'DefaultReparto', 'bit not null', '0', 'Reparto aziendale di defalut'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 1, getdate())
	print '0.0001 fine script'

end
go
-- -------------------------------------------------------------
-- #0.0002 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0001 begin

	print '0.0002 inizio script'

	-- DEPRECATO perchè la gestione è già presente in Operatori
	exec dbo.asp_du_DropColumn 'DO', 'xMOOperatori'

	-- Aggiungo la tabella xMOProgramma
	if dbo.afn_du_IsTable('xMOProgramma') = 0
		exec asp_du_AddTable 'xMOProgramma', 2,'Programmi di moovi'

	exec asp_du_AddAlterColumn 'xMOProgramma'	, 'Descrizione'	, 'varchar(50) not null'	, ''	, 'Descrzione del programma'


	-- Aggiungo a DO la gestione dei programmi
	exec asp_du_addaltercolumn 'DO', 'xCd_xMOProgramma', 'char(2)	null'	, ''		, 'Codice programma di moovi'

		-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 2, getdate())
	print '0.0002 fine script'

end
go
-- -------------------------------------------------------------
-- #0.0003 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0002 begin

	print '0.0003 inizio script'

	-- Aggiunta dei programmi
	Insert Into xMOProgramma	(Cd_xMOProgramma, Descrizione) 
						Values	('DO', 'Ciclo documentale standard'),
								('PR', 'Ciclo documentale da prelievo')

	Update DO Set xCd_xMOProgramma = 'DO' Where xMOAttivo = 1

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 3, getdate())
	print '0.0003 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0004 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0003 begin

	print '0.0004 inizio script'

	exec asp_du_DropTable 'xMODOControllo'

	exec asp_du_DropColumn 'xMOControllo', 'TipoControllo'

	exec asp_du_DropColumn 'DO', 'xMOControlli'
	exec asp_du_AddAlterColumn 'DO', 'xMOControlli', 'xml null', '', 'Se nullo il documento non ha controlli; Se specificato uno o più controlli il documento avrà solo da quelli indicati'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 4, getdate())
	print '0.0004 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0005 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0004 begin

	print '0.0005 inizio script'

	-- Tabella per menù personalizzato
	if dbo.afn_du_IsTable('xMOMenu') = 0
		exec asp_du_AddTable 'xMOMenu', 0, 'Menu personalizzato'
	
	exec asp_du_AddAlterColumn 'xMOMenu'	, 'Descrizione'			, 'varchar(20) not null'	, ''		, 'Descrizione del menù personalizzato'
	exec asp_du_addaltercolumn 'xMOMenu'	, 'xCd_xMOProgramma'	, 'char(2) null'			, ''		, 'Codice programma di moovi'
	exec asp_du_addaltercolumn 'xMOMenu'	, 'Cd_DO'				, 'char(3) null'			, ''		, 'Codice documento FISSO associato al programma'
	exec asp_du_addaltercolumn 'xMOMenu'	, 'Icona'				, 'varchar(50) null'		, ''		, 'Icona del menù'
	exec asp_du_addaltercolumn 'xMOMenu'	, 'Colore'				, 'varchar(50) null'		, ''		, 'Colore del menù'
	exec asp_du_addaltercolumn 'xMOMenu'	, 'Terminali'			, 'xml null'				, '' 		, 'Se nullo il menù viene gestito da tutti i terminali di MOOVI; Se specificato uno o più codici terminale il documento sarà gestito solo da quelli indicati'
	exec asp_du_AddAlterColumn 'xMOMenu'	, 'Operatori'			, 'xml null'				, ''		, 'Se nullo il menù viene gestito da tutti gli operatori di MOOVI; Se specificato uno o più codici operatori il documento sarà gestito solo da quelli indicati (ha prevalenza su xMOTerminali)'
	exec asp_du_AddAlterColumn 'xMOMenu'	, 'Note'				, 'varchar(max) null'		, ''		, 'Note'
	
	-- Aggiunge la gestione del tipo di focus al terminale
	exec asp_du_AddAlterColumn 'xMOTerminale', 'SetFocus'			, 'smallint not null'		, '1'		, 'Imposta la tipologia di focus nei campi (0 = none; 1 = standard; )'

	-- Aggiunge la modalità di inserimento sequenziale del Bc
	exec asp_du_AddAlterColumn 'xMOBC'			, 'Detail'			, 'bit not null'			, '0'		, 'Il barcode può essere inserito in modo sequenziale'

	-- Data di scadenza della matricola generata dalla linea
	exec asp_du_AddAlterColumn 'xMOMatricola', 'DataScadenza'		, 'smalldatetime not null'	, 'getdate()', 'Data di scadenza del lotto prodotto'

	-- Listener abilitato anche per operatore di Arca
	exec asp_du_AddAlterColumn 'xMOListener', 'Operatori'			, 'xml null'				, ''		, 'Se nullo il listener viene aperto da tutti gli operatori di MOOVI;'
	
	-- Listener coda consente di salvare anche l'Id di RL e/o TR
	exec asp_du_AddAlterColumn 'xMOListenerCoda'	, 'Id_xMORL'		, 'int null'				,''			, 'Identificativo del documento RL di riferimento'
	exec asp_du_AddAlterColumn 'xMOListenerCoda'	, 'Id_xMOTR'		, 'int null'				,''			, 'Identificativo del documento TR di riferimento'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 5, getdate())
	print '0.0005 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0006 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0005 begin

	print '0.0006 inizio script'

	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MooviURL'		, 'varchar(250) null'				,''			, 'URL dell''hompage di MOOVI'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 6, getdate())
	print '0.0006 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0007 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0006 begin

	print '0.0007 inizio script'

	exec asp_du_AddAlterColumn 'xMOListener'	, 'ComputerName'		, 'varchar(50) null'				,''			, 'Nome del Pc associato al listener'

	-- Aggiorna il nome del Pc come il codice
	exec('update xMOListener set ComputerName = Cd_xMOListener');

	-- Imposta il nome del computer come obbligatorio
	exec asp_du_AddAlterColumn 'xMOListener'	, 'ComputerName'		, 'varchar(50) not null'			,''			, 'Nome del Pc associato al listener'

	exec asp_du_addaltercolumn 'xMOListener'	, 'IP'					, 'varchar(39) not null'			, ''		, 'Indirizzo Ip del Listener'

	-- Aggiorna il listenerport per i valori nulli
	declare @ListenPort int
	declare @Id_xMOListener int 

	set @ListenPort = isnull((select MAX(@ListenPort) + COUNT(*) from xMOListener), 4001)

	declare @lis cursor 
	set @lis = cursor for select Id_xMOListener from xMOListener 
	open @lis
	fetch next from @lis into @Id_xMOListener

	while (@@fetch_status = 0)
	begin
		update xMOListener set ListenPort = @ListenPort, ReplayPort = @ListenPort + 1 where Id_xMOListener = @Id_xMOListener
		set @ListenPort = @ListenPort + 2
		fetch next from @lis into @Id_xMOListener
	end
	close @lis
	deallocate @lis

	exec asp_du_addaltercolumn 'xMOListener'		, 'ListenPort'			, 'int not null'				, ''			, 'Indirizzo socket del Listener'
	exec asp_du_addaltercolumn 'xMOListener'		, 'ReplayPort'			, 'int not null'				, ''			, 'Indirizzo socket di risposta del Listener al terminale'

	-- Aumenta la descrizione dei controlli
	exec asp_du_AddAlterColumn 'xMOControllo'		, 'Descrizione'			, 'varchar(150) not null'		, ''			, 'Descrzione del ciclo attivo'

	-- Controlli disponibili da associare alla generazione di un documento
	insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('LOT/SCA/ALERT1', 'Data scadenza del lotto troppo vicina (tra %1 giorni)', 1)
	insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('LOT/PRO/ALERT1', 'Data produzione del lotto troppo recente (prodotto da %1 giorni)', 1)


	-- ATTENZIONE sostituire a mano i nomi delle tabelle
	-- xMOMatricola		--> Id_DoRig			--> Id_DORig
	-- xMORL			--> Id_DoTes			--> Id_DOTes

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 7, getdate())
	print '0.0007 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0008 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
/*
	Attenzione la versione 0.0008 è quella che rinomina completamente xMOTRTes in xMOTR
	questo viene effettuato con lo script esterno TR_Rebuild.
	Se la versione corrente contiene la tabella xMOTR lo script continua 
*/
if cast(@CurrVer as numeric(18, 4)) = 0.0007 and not exists(select * from sys.all_objects where name = 'xMOTR') begin
	print '-------------------------------------------------------------------------------------------'
	print 'ATTENZIONE!!! Eseguire lo script TR_Rebuild manualmente per continuare con l''aggiornamento'
	print '-------------------------------------------------------------------------------------------'
end
-- Flusso standard di aggiornamento
if cast(@CurrVer as numeric(18, 4)) = 0.0007 and exists(select * from sys.all_objects where name = 'xMOTR') begin

	print '0.0008 inizio script'

	-- NON incremento la versione fino a quando non è stato eseguito lo script 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 8, getdate())
	print '0.0008 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0009 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0008 begin

	print '0.0009 inizio script'

	-- Gestione COMMESSA

	-- Parametri del documento
	exec asp_du_addaltercolumn 'DO'					, 'xMODOSottoCommessa'		, 'bit not null'			, '0'		, 'Il documento ha attiva la SottoCommessa è attivo'
	-- Testa di xMORL
	exec asp_du_AddAlterColumn 'xMORL'				, 'Cd_DOSottoCommessa'		, 'varchar(20) null'		, ''		, 'Codice Sottocommessa'
	-- Righe di xMORLRig
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'Cd_DOSottoCommessa'		, 'varchar(20) null'		, ''		, 'Codice Sottocommessa'

	-- Lotto dei movimenti interni
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovIntLotto'				, 'bit not null'			, '0'		, 'Se attivo gestisce il lotto per i TRASFERIMENTI interni'

	-- Stato del TRRig_A che indica lo stato del trasferimento
	exec asp_du_AddAlterColumn 'xMOTRRig_A'			, 'Stato'					, 'smallint not null'		, '0'		, 'Stato del trasferimento 0 = in compilazione 1 = chiuso'

	-- Aggiunge il campo Id_MgMovInt per i trasferimenti interni
	exec asp_du_AddAlterColumn 'xMOTR'				, 'Id_MgMovInt'				, 'int null'				, ''		, 'Identificativo del movimento interno generato'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 9, getdate())
	print '0.0009 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0010 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0009 begin

	print '0.0010 inizio script'

	-- Packing list
	if dbo.afn_du_IsTable('xMORLRigPackList') = 0
		exec asp_du_AddTable 'xMORLRigPackList', 0, 'Moovi Packing List'
	
	exec asp_du_AddAlterColumn 'xMORLRigPackList'	, 'Id_xMORLRig'		, 'int not null'			, ''		, 'Riferimento alla riga delle rilevazioni'
	exec asp_du_AddAlterColumn 'xMORLRigPackList'	, 'PackListRef'		, 'varchar(20) not null'	, ''		, 'Codice unità logistica'
	exec asp_du_AddAlterColumn 'xMORLRigPackList'	, 'Qta'				, 'numeric(18,8) not null'	, '0'		, 'Quantità inserita nell''unità logistica'
	
	-- Codice raggruppamento per le righe (utile in fase di generazione dei documenti)
	exec asp_du_AddAlterColumn 'xMORLRig'			, 'CodRag'			, 'int null'				, ''		, 'Codice raggruppamento righe per generazione doc'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 10, getdate())
	print '0.0010 fine script'
end
go

-- -------------------------------------------------------------
-- #0.0011 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0010 begin

	print '0.0011 inizio script'
	
	exec asp_du_DropColumn 'xMOTerminale'	, 'MovIntUbicazione'
	
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MooviURL'		, 'varchar(250) null'			,''			, 'URL dell''hompage di MOOVI'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 11, getdate())
	print '0.0011 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0012 Versione
-- -------------------------------------------------------------

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0011 begin

	print '0.0012 inizio script'
	
	-- SISTEMAZIONE DELLE IMPOSTAZIONI PER I TRASFERIMENTI
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovTraAbilita'		, 'bit not null'			, '1'			, 'Attiva/Disattiva la gestione dei TRASFERIMENTI interni'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovTraDescrizione'	, 'varchar(30) not null'	, '''Trasferimento''', 'Descrizione di default dei TRASFERIMENTI interni'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovTraUbicazione'	, 'bit not null'			, '0'			, 'Attiva/Disattiva la gestione dell''ubicazione per i TRASFERIMENTI interni'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovTraLotto'			, 'bit not null'			, '0'			, 'Se attivo gestisce il lotto per i TRASFERIMENTI interni'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovTraCommessa'		, 'bit not null'			, '0'			, 'Attiva/Disattiva la gestione dell''ubicazione per i TRASFERIMENTI interni'

	-- Impostazioni generali dell'inventario
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovInvAbilita'		, 'bit not null'			, '1'			, 'Attiva/Disattiva la gestione dell''INVENTARIO'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovInvDescrizione'	, 'varchar(30) not null'	, '''Rettifica'''	, 'Descrizione di default dell''INVENTARIO'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovInvUbicazione'	, 'bit not null'			, '0'			, 'Attiva/Disattiva la gestione dell''ubicazione per l''INVENTARIO'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovInvLotto'			, 'bit not null'			, '0'			, 'Se attivo gestisce il lotto per l''INVENTARIO'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MovInvCommessa'		, 'bit not null'			, '0'			, 'Attiva/Disattiva la gestione dell''ubicazione per l''INVENTARIO'

	-- Tabelle dell'inventario
	if dbo.afn_du_IsTable('xMOIN') = 0
		exec asp_du_AddTable 'xMOIN', 0, 'Testa dell''inventario'
	
	exec asp_du_addaltercolumn 'xMOIN'		, 'Terminale'			, 'varchar(39) not null'	, ''		, 'Indirizzo IP V4 o IP V6 del terminale'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Cd_Operatore'		, 'varchar(20) not null'	, ''		, 'Operatore che ha eseguito il movimento di rettifica di inventario'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Descrizione'			, 'varchar(30) not null'	, ''		, 'Descrizione dell''inventario'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Stato'				, 'smallint null'			, ''		, 'Stato dell''inventario (vedere xmofn_xMOIN_Stato)'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'DataOra'				, 'smalldatetime not null'	,''			, 'Data Ora'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Cd_MGEsercizio'		, 'char(4) not null'		, ''		, 'Codice dell''esercizio'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Cd_MG'				, 'char(5) not null'		, ''		, 'Codice del Magazzino da inventariare'
	exec asp_du_AddAlterColumn 'xMOIN'		, 'Cd_MGUbicazione'		, 'varchar(20) null'		, ''		, 'Ubicazione del magazzino da inventariare'
	
	if dbo.afn_du_IsTable('xMOINRig') = 0
		exec asp_du_AddTable 'xMOINRig', 0, 'Righe dell''inventario'

	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Id_xMOIN'			, 'int not null'				, ''		, 'Identificativo del documento di testa di MOOVI'
	exec asp_du_addaltercolumn 'xMOINRig'		, 'Terminale'			, 'varchar(39) not null'		, ''		, 'Indirizzo IP V4 o IP V6 del terminale'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_Operatore'		, 'varchar(20) not null'		, ''		, 'Operatore che ha eseguito il movimento di rettifica di inventario'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_AR'				, 'varchar(20) not null'		, ''		, 'Articolo da inventariare'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Quantita'			, 'numeric(18,8) not null'		, '0'		, 'Quantita in giacenza'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'QtaRilevata'			, 'numeric(18,8) null'			, ''		, 'Quantita rettificata (se nulla non è stata validata dall''operatore)'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_ARMisura'			, 'char(2) not null'			, ''		, 'unita di misura del articolo'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'FattoreToUM1'		, 'numeric(18,8) not null'		, '1'		, 'Fattore di conversione rispetto all''unità di misura principale'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_DOSottoCommessa'	, 'varchar(20) null'			, ''		, 'Codice Sottocommessa'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_ARLotto'			, 'varchar(20) null'			, ''		, 'Lotto del prodotto'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_MG'				, 'char(5) null'				, ''		, 'Codice del Magazzino da inventariare'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Cd_MGUbicazione'		, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino da inventariare'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'InLavorazione'		, 'bit not null'				, '0'		, 'Vero se la riga è attualmente attiva sul client'
	exec asp_du_AddAlterColumn 'xMOINRig'		, 'Id_MGMovInt'			, 'int null'					, ''		, 'Identificativo del movimento interno in Arca'


	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 12, getdate())
	print '0.0012 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0013 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0012 begin

	print '0.0013 inizio script'

	if exists(select * from sys.all_columns where object_name(object_id) = 'xMOImpostazioni' And name = 'MovIntAbilita') begin
		-- Aggiorno i nuovi campi con i valori dei vecchi
		exec ('update xMOImpostazioni set MovTraAbilita = MovIntAbilita, MovTraDescrizione = MovIntDescrizione, MovTraUbicazione = MovIntUbicazione, MovTraLotto = MovIntLotto')
		-- elimino i campi vecchi
		exec asp_du_DropColumn 'xMOImpostazioni'	, 'MovIntAbilita'		
		exec asp_du_DropColumn 'xMOImpostazioni'	, 'MovIntDescrizione'	
		exec asp_du_DropColumn 'xMOImpostazioni'	, 'MovIntUbicazione'	
		exec asp_du_DropColumn 'xMOImpostazioni'	, 'MovIntLotto'			
	end

	if exists(select * from sys.all_columns where object_name(object_id) = 'xMOTerminale' And name = 'MovIntAbilita') begin
		-- elimino i campi vecchi
		exec asp_du_DropColumn 'xMOTerminale'		, 'MovIntAbilita'		
	end

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 13, getdate())
	print '0.0013 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0014 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0013 begin

	print '0.0014 inizio script'

	exec asp_du_AddAlterColumn 'xMOLinea'	, 'MatAttivo'				, 'bit not null'			, '0'		, 'Vero se la linea è attiva per la generazione dei CPI per Matricola'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 14, getdate())
	print '0.0014 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0015 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0014 begin

	print '0.0015 inizio script'

	exec asp_du_addaltercolumn 'DOTes'				, 'xMOCodSpedizione'	, 'varchar(15) null'	, ''		, 'Codice Spedizione'
	exec asp_du_addaltercolumn 'xMORL'				, 'CodSpedizione'		, 'varchar(15) null'	, ''		, 'Codice Spedizione'

	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'SpeAbilita'			, 'bit not null'		, '0'		, 'Vero attiva la gestione della spedizione'
	--exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'SpeEtichetta'		, 'varchar(20) null'	, ''		, 'Campo per il nome della spedizione'

	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'SpeEtichetta'		, 'varchar(20) not null', '''Spedizione''', 'Campo per il nome della spedizione'

	-- Aggiunge il programma Spedizione
	if not exists(select * from xMOProgramma where Cd_xMOProgramma = 'SP') begin
		insert into xMOProgramma (Cd_xMOProgramma, Descrizione) Values ('SP', 'Spedizione')
	end

	exec asp_du_addaltercolumn 'DO'					, 'xMOSpeAbilita'		, 'bit not null'		, '0'		, 'Abilita il Codice Spedizione (su Varie)'

	-- Top dell'inventario massivo
	exec asp_du_addaltercolumn 'xMOIN'				, 'Top'				, 'int not null'		, '100'		, 'Top inventario massivo'

	-- Anagrafica unità logistiche
	if dbo.afn_du_IsTable('xMOUniLog') = 0
		exec asp_du_AddTable 'xMOUniLog', 20, 'Anagrafica Unità Logistiche'
	
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'Descrizione'			, 'varchar(30) not null'	, ''	, 'Descrizione Unità Logistica'
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'ULDefault'			, 'bit not null'			, '0'	, 'Unità di misura di default'
	exec asp_du_addaltercolumn	'xMOUniLog'		, 'Terminali'			, 'xml null'				, '' 	, 'Se nullo l''unità logistica viene gestita da tutti i terminali di MOOVI;'
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'Operatori'			, 'xml null'				, ''	, 'Se nullo l''unità logistica viene gestita da tutti i operatori di MOOVI;'
	-- Fisso a Kg
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'PesoTaraMks'			, 'numeric(18,4) not null'	, '0'	, 'Peso tara in Kg'
	-- Fisso a Metri
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'AltezzaMks'			, 'numeric(18,4) not null'	, '0'	, 'Altezza in metri'
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'LunghezzaMks'		, 'numeric(18,4) not null'	, '0'	, 'Lunghezza in metri'
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'LarghezzaMks'		, 'numeric(18,4) not null'	, '0'	, 'Larghezza in metri'
	-- Fisso a Metri Cubi
	exec asp_du_DropColumn		'xMOUniLog'		, 'VolumeMks'
	exec asp_du_AddAlterColumn	'xMOUniLog'		, 'VolumeMks'			, ' AS (isnull([AltezzaMks]*[LunghezzaMks]*[LarghezzaMks],0))', '', 'Volume esprsso in metri cubi'

	-- Rilevazioni e Packing list definite (pesi e volumi delle Unità Logistiche)
	if dbo.afn_du_IsTable('xMORLPackListRef') = 0
		exec asp_du_AddTable 'xMORLPackListRef', 0, 'Rilevazioni e Packing list definite'

	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'Id_xMORL'		, 'int not null'			, ''		, 'Riferimento alla testa delle rilevazioni'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'PackListRef'		, 'varchar(20) not null'	, ''		, 'Riferimento al codice assegnato dall''operatore della packing list'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'Cd_xMOUniLog'	, 'varchar(20) null'		, ''		, 'Codice Unità Logistica'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'PesoTaraMks'		, 'numeric(18,4) not null'	, '0'		, 'Peso tara in Kg'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'PesoNettoMks'	, 'numeric(18,4) not null'	, '0'		, 'Peso netto in Kg'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'PesoLordoMks'	, 'numeric(18,4) not null'	, '0'		, 'Peso lordo'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'AltezzaMks'		, 'numeric(18,4) not null'	, '0'		, 'Altezza in metri'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'LunghezzaMks'	, 'numeric(18,4) not null'	, '0'		, 'Lunghezza in metri'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'LarghezzaMks'	, 'numeric(18,4) not null'	, '0'		, 'Larghezza in metri'
	exec asp_du_DropColumn		'xMORLPackListRef'	, 'VolumeMks'
	exec asp_du_AddAlterColumn	'xMORLPackListRef'	, 'VolumeMks'		, ' AS (isnull([AltezzaMks]*[LunghezzaMks]*[LarghezzaMks],0))', '', 'Volume esprsso in metri cubi'

	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'PesoFattore'			, 'numeric(25,12) not null'	, '1.0'		, 'Unità di misura in cui sono espressi i Pesi (fattore moltiplicativo per ottenere Kg)'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'PesoLordoMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'PesoLordoMks'		, ' AS (isnull([PesoFattore]*[PesoLordo],(0)))'	, ''		, 'Peso Lordo in Kg'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'PesoNettoMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'PesoNettoMks'		, ' AS (isnull([PesoFattore]*[PesoNetto],(0)))'	, ''		, 'Peso Netto in Kg'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'Altezza'				, 'numeric(18,4) not null'	, '0'		, 'Altezza'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'Lunghezza'			, 'numeric(18,4) not null'	, '0'		, 'Lunghezza'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'Larghezza'			, 'numeric(18,4) not null'	, '0'		, 'Larghezza'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'DimensioniFattore'	, 'numeric(25,12) not null'	, '1.0'		, 'Fattore in cui sono espresse Altezza/Lunghezza/Larghezza'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'AltezzaMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'AltezzaMks'			, ' AS (isnull([DimensioniFattore]*[Altezza],(0)))', ''		, 'Altezza in metri'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'LunghezzaMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'LunghezzaMks'		, ' AS (isnull([DimensioniFattore]*[Lunghezza],(0)))', ''	, 'Lunghezza in metri'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'LarghezzaMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'LarghezzaMks'		, ' AS (isnull([DimensioniFattore]*[Larghezza],(0)))', ''	, 'Larghezza in metri'
	--exec asp_du_DropColumn		'xMORLRigPackList'	, 'VolumeMks'
	--exec asp_du_AddAlterColumn	'xMORLRigPackList'	, 'VolumeMks'			, ' AS (isnull((((([DimensioniFattore]*[Altezza])*[DimensioniFattore])*[Lunghezza])*[DimensioniFattore])*[Larghezza],(0)))', '', 'Volume esprsso in metri cubi'


	-- Data validità/scadenza della lettura (utile per la generazione del Lotto in Arca)
	exec asp_du_addaltercolumn 'xMORLRig'		, 'DataScadenza'		, 'smalldatetime null'	, ''		, 'Data validità del lotto'

	exec asp_du_addaltercolumn 'DO'				, 'xMOPrelievo'			, 'smallint not null'	, '0'		, 'Tipo di Prelievo da applicare: 0 = nessun prelievo; 1 = Prelievo; 2 = Copia righe;'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 15, getdate())
	print '0.0015 fine script'

end
go

-- -------------------------------------------------------------
-- #0.0016 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0015 begin

	print '0.0016 inizio script'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 16, getdate())
	print '0.0016 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0017 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0016 begin

	print '0.0017 inizio script'

	exec asp_du_AddAlterColumn 'xMORL'			, 'Cd_DOCaricatore'		, 'char(3)		null'		, ''	, 'Codice del caricatore (del piede del documento)'
																										
	-- Creo il nuovo campo in DOTes che sostituirà xMOCodSpedizione										
	exec asp_du_AddAlterColumn 'DOTes'			, 'xCd_xMOCodSpe'		, 'varchar(15)	null'		, ''	, 'Codice della spedizione'

	-- Creo il nuovo campo in xMORL che sostituirà CodSpedizione										
	exec asp_du_AddAlterColumn 'xMORL'			, 'Cd_xMOCodSpe'		, 'varchar(15)	null'		, ''	, 'Codice della spedizione'

	-- Creo l'anagrafica xMOCodSpe
	if dbo.afn_du_IsTable('xMOCodSpe') = 0
		exec asp_du_AddTable 'xMOCodSpe', 20, 'Anagrafica Spedizione'
	
	exec asp_du_AddAlterColumn	'xMOCodSpe'		, 'Descrizione'			, 'varchar(30)	null'	, ''	, 'Descrizione della Spedizione'
	exec asp_du_AddAlterColumn	'xMOCodSpe'		, 'Data'				, 'smalldatetime null'	, ''	, 'Data della Spedizione'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 17, getdate())
	print '0.0017 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0018 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0017 begin

	print '0.0018 inizio script'

	-- Insert into anagrafica xMOCodSpe da DOTes
	exec ('insert into xMOCodSpe (Cd_xMOCodSpe, Descrizione) select distinct xMOCodSpedizione, ''Spedizione '' + ltrim(xMOCodSpedizione) from DoTes where xMOCodSpedizione is not null')
	
	-- Aggiorno il campo xCd_xMOCodSpe in DOTes
	exec ('update DOTes set xCd_xMOCodSpe = xMOCodSpedizione where xMOCodSpedizione is not null')
	-- Drop del campo xMOCodSpedizione in DOTes
	exec asp_du_DropColumn 'DOTes', 'xMOCodSpedizione'

	-- Aggiorno il campo Cd_xMOCodSpe in xMORL
	exec ('update xMORL set Cd_xMOCodSpe = CodSpedizione where CodSpedizione is not null')
	-- Drop del campo CodSpedizione in xMORL
	exec asp_du_DropColumn 'xMORL', 'CodSpedizione'

	-- Elimina il campo SpeEtichetta: ora è fisso con spedizione
	exec asp_du_DropColumn 'xMOImpostazioni'	, 'SpeEtichetta'		

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 18, getdate())
	print '0.0018 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0019 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0018 begin

	print '0.0019 inizio script'
	-- Impostazione per l'attivazione dell'azzeramento del residuo al prelievo di un ordine
	exec asp_du_AddAlterColumn 'DO'			, 'xMOResiduoInPrelievo '		, 'smallint not null'		, '0'	, 'Bit per l'' attivazione dell''azzeramento del residuo in prelievo dell’ordine'


-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 19, getdate())
	print '0.0019 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0020 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0019 begin

	print '0.0020 inizio script'

	exec asp_du_AddAlterColumn 'xMORLRig'			, 'DataOra'				, 'datetime not null'			, '(getdate())', 'Data e ora della lettura'

-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 20, getdate())
	print '0.0020 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0021 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0020 begin

	print '0.0021 inizio script'

	exec asp_du_AddAlterColumn 'DO'					, 'xMOUmConverti'		, 'smallint not null'	, '0'	,	'Converte l''unità di misura (0 = nessuna conversione; 1 = converte l''UM letta in quella del prelievo)'

-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 21, getdate())
	print '0.0021 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0022 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0021 begin

	print '0.0022 inizio script'

	exec asp_du_AddAlterColumn 'DO'					, 'xMOAutoConfirm'		, 'bit not null'	, '0'	,	'Vero imposta l''autoconferma attiva'

	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatSchedule'			, 'numeric(18,8) not null'	, '0'		, 'Se maggiore di zero è il tempo in secondi per l''import dei documenti di carico'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatStart'			, 'numeric(18,8) not null'	, '0'		, 'Secondi da mezzanotte per l''avvio dell''import dei documenti di carico'
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatFattoreMks'		, 'int not null'			, '3600'	, 'Unità di misura di tempo della schedulazione per l''import dei documenti di carico'

	exec asp_du_AddAlterColumn 'xMOControllo'		, 'Parametro1'			, 'numeric(18,8) '			, ''	,  'Campo per la parametrizzazione del controllo (es. giorni, mesi ecc impostabili dall''operatore)'
	exec asp_du_AddAlterColumn 'ARLotto'			, 'xMOBlocco'			, 'bit not null'			, '0'	,  'Blocca l''utilizzo del lotto rendendolo non prelevabile nei documenti'

	-- Stato da nullabile è diventato not null def 0
	exec asp_du_AddAlterColumn 'xMORL'				, 'Stato'				, 'smallint not null'			, '0'		, 'Stato della rilevazione (vedere xmofn_xMORL_Stato)'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 22, getdate())
	print '0.0022 fine script'

end 
go


-- -------------------------------------------------------------
-- #0.0023 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0022 begin

	print '0.0023 inizio script'


	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 23, getdate())
	print '0.0023 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0024 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0023 begin

	print '0.0024 inizio script'

	-- Stato da nullabile è diventato not null def 0
	exec asp_du_AddAlterColumn 'xMORL'				, 'Stato'				, 'smallint not null'			, '0'		, 'Stato della rilevazione (vedere xmofn_xMORL_Stato)'

	-- Normalizza i dati di Stato di xMORL
	exec ('update xMORL set Stato = 3 where Stato = 2 And isnull(Id_DoTes, 0) = 0') -- Annullto da 2 passa a 3
	exec ('update xMORL set Stato = 2 where Stato = 1 And isnull(Id_DoTes, 0) > 0') -- Storicizzato da 1 passa a 2


	-- Aggiunta campi nel piede della rl per inserire il peso e il volume di eventuali UL aggiuntivi alla pk (es: pallet contenenti scatole che a loro volta contengono articoli)
	exec asp_du_AddAlterColumn 'xMORL'				, 'PesoExtraMks'		, 'numeric(18,4) not null'			, '0'		, 'Peso di eventuali UL aggiuntivi alla packing list (es:pallet)'
	exec asp_du_AddAlterColumn 'xMORL'				, 'VolumeExtraMks'		, 'numeric(38,6) not null'			, '0'		, 'Volume di eventuali UL aggiuntivi alla packing list'


	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'Verbose'				, 'bit not null'					, '0'		, ''

	-- Controllo della matricola presente in letture in corso da altri operatori
	insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('MAT/LET/OPE', 'Matricola presente in letture in corso da altri operatori', 1)

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 24, getdate())
	print '0.0024 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0025 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0024 begin

	print '0.0025 inizio script'

	-- Aggiunta del campo Attiva che definisce se la spedizione deve essere visualizza in Moovi a prescindere se i documenti appartenenti ad una spe siano stati evasi o meno
	exec asp_du_AddAlterColumn 'xMOCodSpe'		, 'Attiva'		, 'bit'		, '1'	, '1 = Attiva quindi visibile in Moovi, 0 = Disattiva, non visualizzata in Moovi '
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 25, getdate())
	print '0.0025 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0026 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0025 begin

	print '0.0026 inizio script'

	-- Campo per abilitare lo scarico dei CPI da P\C
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'MatPC'				, 'bit not null'			, '0'		, 'Se attivo gestisce i carichi come P/C'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 26, getdate())
	print '0.0026 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0027 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0026 begin

	print '0.0027 inizio script'

	-- Campo deprecato Stato 
	exec dbo.asp_du_DropColumn 'xMOTRRig_A', 'Stato'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 27, getdate())
	print '0.0027 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0028 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0027 begin

	print '0.0028 inizio script'

	-- tabella contenente i parametri web 
	IF dbo.afn_du_IsTable('xMOImpostazioniWeb')  = 0
		exec asp_du_AddTable 'xMOImpostazioniWeb', 0, 'MOOVI - Parametri per impostazioni Web'

	exec asp_du_AddAlterColumn 'xMOImpostazioniWeb'		, 'PackingList'		, 'bit not null'	, '1'		, 'Atttiva/Disattiva la packing in moovi a prescindere dalla configurazione del documento in arca'

	-- Inserisco un record nella tabella 
	insert into xMOImpostazioniWeb (packinglist)
	values(1)

	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 28, getdate())
	print '0.0028 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0029 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0028 begin

	print '0.0029 inizio script'

	exec asp_du_AddAlterColumn 'xMOMatricola'	, 'Disattiva'		, 'bit not null'		, '0'		, 'Vero se la matricola non è più disponibile in azienda'

	exec asp_du_AddAlterColumn 'DO'				, 'xMOMatDisp'		, 'smallint not null'	, '0'		, 'Tipologia di azione effettuata sulla disponibilità della matricola (0 = Nessuna azione; 1 = Rende la matricola DISPONIBILE; 2 = Rende la matricola NON disponibile)'

	-- Disattiva i documenti non abilitabili
	update DO set xMOAttivo = 0 where xMOAttivo = 1 AND TipoDocumento NOT IN ('B', 'M', 'D', 'G', 'V', 'T', 'R')
	
	-- Aggiunge il controllo per la disponibilità della matricola
	insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('MAT/DISP/ALERT', 'Matricola non disponibile.', 1)

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 29, getdate())
	print '0.0029 fine script'

end 
go


-- -------------------------------------------------------------
-- #0.0030 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0029 begin

	print '0.0030 inizio script'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 30, getdate())
	print '0.0030 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0031 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0030 begin

	print '0.0031 inizio script'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 31, getdate())
	print '0.0031 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0032 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0031 begin

	print '0.0032 inizio script'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 32, getdate())
	print '0.0032 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0033 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0032 begin

	print '0.0033 inizio script'

	exec asp_du_AddAlterColumn 'DO'		, 'xMOAA'		, 'bit not null'	, '0'	,	'Vero abilita l''acquisizione degli alias in fase di lettura in moovi'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 33, getdate())
	print '0.0033 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0034 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0033 begin

	print '0.0034 inizio script'

	-- Tabella dell'anagrafica della giacenza delle matricole
	if dbo.afn_du_IsTable ('xMOMatGiac') = 0
		exec asp_du_AddTable 'xMOMatGiac', 0, 'MOOVI - Giacenza per matricola'

	exec asp_du_AddAlterColumn 'xMOMatGiac'	, 'Matricola'			, 'varchar(80)		not null'		, ''			, 'Codice matricola'
	exec asp_du_AddAlterColumn 'xMOMatGiac'	, 'Cd_AR'				, 'varchar(20)		not null'		, ''			, 'Articolo a cui è associata la matricola'
	exec asp_du_AddAlterColumn 'xMOMatGiac'	, 'Cd_ARLotto'			, 'varchar(20)		null'			, ''			, 'Lotto del prodotto'
	exec asp_du_AddAlterColumn 'xMOMatGiac'	, 'Quantita'			, 'numeric(18,8)	not null'		, '0'			, 'Quantita in giacenza'	
	exec asp_du_AddAlterColumn 'xMOMatGiac'	, 'DataOra'				, 'smalldatetime	not null'		, 'getdate()'	, 'Data ora ultimo movimento'	

	exec asp_du_AddAlterColumn 'AR'			, 'xMOAbilitaMatGiac'	, 'bit not null'					, '0'			,	'Vero abilita la gestione della giacenza per matricola'

	exec asp_du_AddAlterColumn 'DO'			, 'xMOMatGiacTipo'		, 'smallint not null'				, '0'			, 'Tipologia di azione effettuata sulla giacenza della matricola (0 = Nessuna azione; 1 = Movimento positivo; 2 = Movimento negativo)'

	-- Aggiunge il controllo sulla disponibilità della giacenza di matricola per le letture effettuate.
	insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('MAT/GIAC/ALERT', 'Giacenza della matricola esaurita.', 1)

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 34, getdate())
	print '0.0034 fine script'

end 
go

-- -------------------------------------------------------------
-- #0.0035 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0034 begin

	print '0.0035 inizio script'

	exec asp_du_addaltercolumn 'xMOTR', 'Cd_DOSottoCommessa'		, 'varchar(20) null'	, '' 		, 'Codice sottocommessa'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 35, getdate())
	print '0.0035 fine script'

end 
go


-- -------------------------------------------------------------
-- #0.0035 Versione
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0035 begin

	print '0.0036 inizio script'

	-- Impostazione Stoccaggio attivo
	exec asp_du_AddAlterColumn 'xMOImpostazioni'	, 'Stoccaggio'	, 'bit not null'	, '0'			, 'Vero se gestione dello stoccaggio è attiva per MOOVI'

	-- Aggiunta del campo documento attivo per lo stoccaggio (sempre modificabile a prescidere se il doc è attivo per moovi come per spedizione)
	exec asp_du_AddAlterColumn 'DO'	, 'xMOStoccaggio'	, 'bit not null'	, '0'			, 'Vero se il documento è attivo per la generazione dello stoccaggio'

	-- Aggiunta campi per la mappatura grafica nel Magazzino
	exec asp_du_AddAlterColumn 'MG'	, 'xMOImg'	, 'varbinary(max) not null'	, '0x'			, 'Immagine raster del magazzino grafico'

	exec asp_du_addaltercolumn 'xMOTR', 'Cd_xMOProgramma', 'char(2)	null'	, ''		, 'Codice programma di moovi (TI = Trasferimenti interni; SM = Stoccaggio Merce)'
	
	-- Anagrafica corsie -- DROP TABLE xMOMGCorsia
	if dbo.afn_du_IsTable ('xMOMGCorsia') = 0 begin
		exec asp_du_AddTable 'xMOMGCorsia', 0, 'MOOVI - Anagrafica corsie'
		exec('alter table xMOMGCorsia drop constraint PK_xMOMGCorsia')


		exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'Cd_xMOMGCorsia'		, 'char(5)		not null'	, ''			, 'Codice corsia associato'
		exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'Cd_MG'				, 'char(5)		not null'	, ''			, 'Codice magazzino associato'

		exec('alter table xMOMGCorsia add constraint PK_xMOMGCorsia PRIMARY KEY CLUSTERED 
		(
			Cd_MG ASC,
			Cd_xMOMGCorsia ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]')

		exec('
			ALTER TABLE xMOMGCorsia ADD  CONSTRAINT IK_xMOMGCorsia UNIQUE NONCLUSTERED 
			(
				Id_xMOMGCorsia ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		')
	end
	
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'Descrizione'			, 'varchar(80)	not null'	, ''			, 'Descrizione corsia'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'EtiX'				, 'int			not null'	, ''			, 'Posizione X della corsia'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'EtiY'				, 'int			not null'	, ''			, 'Posizione Y della corsia'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'Righe'				, 'int			not null'	, ''			, 'Numero di righe'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'Colonne'				, 'int			not null'	, ''			, 'Numero di colonne'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'CPSequenza'			, 'int			not null'	, '0'			, 'Ordinamento delle corsie nel magazzino per il ciclo passivo'
	exec asp_du_AddAlterColumn 'xMOMGCorsia'	, 'CASequenza'			, 'int			not null'	, '0'			, 'Ordinamento delle corsie nel magazzino per il ciclo attivo'

	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xCd_xMOMGCorsia'		, 'char(5)			null'		, ''			, 'Codice corsia associato'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOStato'			, 'char(1)			not null'	, '''A'''		, 'Stato dell''ubicazione per la mappatura di magazzino (A = Attiva; B = Temporaneamente bloccata; D = Disattiva;)'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOTipo'				, 'char(1)			not null'	, '''S'''		, 'Tipo di ubicazione Picking, Stoccaggio..'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMORiga'				, 'int				null'		, ''			, 'Riga della corsia'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOColonna'			, 'int				null'		, ''			, 'Colonna della corsia'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOLarghezzaMks'		, 'numeric (18,8)	not null'	, '0'			, 'Larghezza dell''ubicazione (metri)'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOAltezzaMks'		, 'numeric (18,8)	not null'	, '0'			, 'Altezza dell''ubicazione (metri)'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOProfonditaMks'	, 'numeric (18,8)	not null'	, '0'			, 'Profondità dell''ubicazione (metri)'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOPesoMaxMks'		, 'numeric (18,8)	not null'	, '0'			, 'Peso massimo supportato dall''ubicazione (chilogrammi)'
	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOVolumeMaxMks'		, 'numeric (18,8)	not null'	, '0'			, 'Volume massimo accoglibile dall''ubicazione (metri cubi)'

	-- Trasferimenti proposti per CP Stoccaggio
	if dbo.afn_du_IsTable ('xMOTRRig_T') = 0
		exec asp_du_AddTable 'xMOTRRig_T', 0, 'Trasferimenti temporanei proposti'

	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Id_xMOTR'			, 'int not null'				, ''		, 'Identificativo della rilevazione di trasferimento'
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Id_xMOTRRig_P'		, 'int not null'				, ''		, 'Identificativo univoco del movimento di trasferimento di partenza'	
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Id_xMOTRRig_A'		, 'int null'					, ''		, 'Identificativo univoco del movimento di trasferimento di arrivo (per Stato = 1 Stoccato)'	
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'QtaUMP'				, 'numeric(18,8)'				, ''		, 'Quantita nell''unità di misura di xmotrrig_p'
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Cd_MG_A'				, 'char(5) not null'			, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Cd_MGUbicazione_A'	, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOTRRig_T'			, 'Tipo'				, 'char(1) not null'			, '''A'''	, 'A = Autoproposto; M = determinato dall''operatore; E = Escluso; S = Stoccato;'
	
	exec asp_du_AddAlterColumn 'ARMGUbicazione'		, 'xMOScortaMinima'		, 'numeric (18,8) not null'		, '0'		, 'Scorta minima per reintegro ubicazione'
	exec asp_du_AddAlterColumn 'ARMGUbicazione'		, 'xMOScortaMassima'	, 'numeric (18,8) not null'		, '0'		, 'Scorta massima accoglibile dall''ubicazione'

	exec asp_du_AddAlterColumn 'xMOTRRig_P'			, 'Esclusioni'			, 'xml null'					, ''		, 'Ubicazioni escluse dall''operatore'

	-- Trasferimenti proposti per CA Packing
	 --if dbo.afn_du_IsTable ('xMORLRig_T') = 0
	 --	exec asp_du_AddTable 'xMORLRig_T', 0, 'Rilevazioni temporanee proposte'
	 
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Id_xMORL'			, 'int not null'				, ''		, 'Identificativo della rilevazione di trasferimento'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Quantita'			, 'numeric(18,8) not null'		, ''		, 'Quantita'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Cd_MG'				, 'char(5) not null'			, ''		, 'Codice del Magazzino di partenza'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Cd_MGUbicazione'		, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Cd_ARLotto'			, 'varchar(20) null'			, ''		, 'Ubicazione del magazzino di partenza'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Peso'				, 'numeric (18,8) null'			, ''		, 'Peso richiesto nell''ubicazione'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Volume'				, 'numeric (18,8) null'			, ''		, 'Volume richiesto nell''ubicazione'
	 --exec asp_du_AddAlterColumn 'xMORLRig_T'			, 'Stato'				, 'smallint not null'			, '0'		, '0 = Proposto; 1 = Stoccato; 2 = Escluso'
	


	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 36, getdate())
	print '0.0036 fine script'

end 
go

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0036 begin

	print '0.0037 inizio script'
	
	exec asp_du_AddAlterColumn 'xMORLRig'	, 'ExtFld'		, 'xml'	, ''	, 'Contiene i valori dei campi personalizzati configurati per il documento in xmofn_DO'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 37, getdate())
	print '0.0037 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0037 begin

	print '0.0038 inizio script'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 38, getdate())
	print '0.0038 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0038 begin

	print '0.0039 inizio script'
	
	-- Campo per l'azzeramento del residuo in prelievo
	exec asp_du_AddAlterColumn 'xMORLPrelievo', 'Azzera'		, 'bit'	, '0'	, 'Vero azzera il residuo in prelievo.'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 39, getdate())
	print '0.0039 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0039 begin

	print '0.0040 inizio script'
	
	exec asp_du_AddAlterColumn 'xMoImpostazioni', 'PrdCd_MG_P'			, 'char(5) null'			, ''			, 'Magazzino dei prodotti finiti per la produzione'
	exec asp_du_AddAlterColumn 'xMoImpostazioni', 'PrdCd_MG_C'			, 'char(5) null'			, ''			, 'Magazzino delle materie prime per la produzione'

	exec asp_du_AddAlterColumn 'xMOLinea'		, 'Cd_MGUbicazione'		, 'varchar(20) null'		, ''			, 'Ubicazione della linea di produzione'
	exec asp_du_AddAlterColumn 'PRRisorsa'		, 'xCd_xMOLinea'		, 'varchar(20) null'		, ''			, 'Codice linea di produzioneassociato alla risorsa'

	exec asp_du_AddAlterColumn 'PRTRAttivita'	, 'xCd_xMOLinea'		, 'varchar(20) null'		, ''			, 'Codice linea di produzioneassociato letto'

	exec asp_du_AddAlterColumn 'PRTRMateriale'	, 'xTerminale'			, 'varchar(39) null'		, ''			, 'IP del terminale che ha eseguito la lettura'
	exec asp_du_AddAlterColumn 'PRTRMateriale'	, 'xCd_Operatore'		, 'varchar(20) null'		, ''			, 'Operatore che ha eseguito la lettura'
	exec asp_du_AddAlterColumn 'PRTRMateriale'	, 'xId_PrBLMateriale'	, 'int null'				, ''			, 'Il materiale dichiarato dall''operatore'
	exec asp_du_AddAlterColumn 'PRTRMateriale'	, 'xDataOra'			, 'datetime null'			, 'getdate()'	, 'Dataora inserimento materiale'
	exec asp_du_AddAlterColumn 'PRTRMateriale'	, 'xMancante'			, 'bit null'				, '0'			, 'Articolo mancante'

	exec asp_du_AddAlterColumn 'MGUbicazione'	, 'xMOCompleta'			, 'bit			not null'	, '0'			, 'Ubicazione Completa'

	exec sp_refreshview 'PRTRMaterialeEx'
	exec sp_refreshview 'PRTRAttivitaEx'


	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 40, getdate())
	print '0.0040 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0040 begin

	print '0.0041 inizio script'
	
	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 41, getdate())
	print '0.0041 fine script'

end 
go 


declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0041 begin

	print '0.0042 inizio script'

	exec asp_du_AddAlterColumn 'xMOListener'	, 'Polling'		, 'int not null'		, '0'		, '0 nessun polling; > 0 tempo di verifica coda (in secondi)'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 42, getdate())
	print '0.0042 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0042 begin

	print '0.0043 inizio script'

	exec asp_du_AddAlterColumn 'DO'	, 'xMOUMFatt'		, 'smallint not null'		, '0'		, '0 = nessun fattore; 1 = fattore di conversione; 2 = fattore calcolato da quantità UM principale.'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 43, getdate())
	print '0.0043 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0043 begin

	print '0.0044 inizio script'

	exec asp_du_AddAlterColumn 'xMOBC'			, 'Tipo'				, 'int not null'	, ''		, 'Tipo di codifica del barcode (fisso: 1 = GS1; 2 = SSCC; 3 = Barcode strutturato; 4 = IDDR) '
	exec asp_du_addaltercolumn 'xMORLRig'		, 'Id_DORig'			, 'int null'		, '' 		, 'Riferimento alla riga doc prelevata'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 44, getdate())
	print '0.0044 fine script'

end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0044 begin

	print '0.0045 inizio script'
		
	-- Tabella trasferimenti materiali per produzione
	if dbo.afn_du_IsTable ('xMOPRTR') = 0
		exec asp_du_AddTable 'xMOPRTR', 0, 'Moovi - Trasferimenti per Bolle produzione attività'

	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Terminale'			, 'varchar(39) not null'	, ''		, 'IP del terminale che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Cd_Operatore'		, 'varchar(20) not null'	, ''		, 'Operatore che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Id_PrBLAttivita'		, 'int not null'			, ''		, 'Id_PrBLAttivita della Bolla'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Data'				, 'smalldatetime not null'	, ''		, 'Data apertura rilevazione'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Cd_PrRisorsa'		, 'varchar(20) not null'	, ''		, 'Risorsa associata al trasferimento'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Note'				, 'varchar(max) null'		, ''		, 'Note'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Stato'				, 'smallint not null'		, '0'		, 'Stato della rilevazione (0 = In compilazione; 1 = Da storicizzare; 2 = Storicizzata; 3 = Errore)'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'Id_PRTRAttivita'		, 'int null'				, ''		, 'Id_PRTRAttivita geneato'
	exec asp_du_AddAlterColumn 'xMOPRTR'	, 'PercTrasferita'		, 'numeric(18, 2) not null'	, '0'		, 'Valore della percentuale trasferita (calcolata e conferamata dall''operatore)'

	-- Tabella trasferimenti materiali per produzione
	if dbo.afn_du_IsTable ('xMOPRTRRig') = 0
		exec asp_du_AddTable 'xMOPRTRRig', 0, 'Moovi - Trasferimenti per Bolle produzione materiali'

	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Terminale'			, 'varchar(39)		not null'	, ''		, 'IP del terminale che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_Operatore'		, 'varchar(20)		not null'	, ''		, 'Operatore che ha eseguito la richiesta di creazoine e/o stampa'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Id_xMOPRTR'			, 'int				not null'	, ''		, 'Testa trasferimento materiali per Bolla'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Id_PrBLMateriale'	, 'int				not null'	, ''		, 'Identificativo del materiale da trasferire'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'DataOra'				, 'smalldatetime	not null'	, 'getdate()', 'Data ora ultimo movimento'	
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_AR'				, 'varchar(20)		not null'	, ''		, 'Articolo movimentato'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_ARLotto'			, 'varchar(20)		null'		, ''		, 'Lotto del prodotto'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Quantita'			, 'numeric(18,8)	not null'	, '0'		, 'Quantita in giacenza'	
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_ARMisura'			, 'char(2)			not null'	, ''		, 'Unità di misura'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'FattoreToUM1'		, 'numeric(18,8)	not null'	, '1'		, 'Fattore di conversione rispetto all''unità di misura principale'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_MG_P'				, 'char(5)			not null'	, ''		, 'Codice del Magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Cd_MGUbicazione_P'	, 'varchar(20)		null'		, ''		, 'Ubicazione del magazzino di partenza'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Mancante'			, 'bit				not	null'	, '0'		, 'Vero se l''articolo risulta mancante in magazzino'
	exec asp_du_AddAlterColumn 'xMOPRTRRig'	, 'Note'				, 'varchar(max)		null'		, ''		, 'Note riga'

	-- Elimina i campi deprecati 
	exec asp_du_DropColumn 'PRTRAttivita', 'xCd_xMOLinea'

	exec sp_refreshview 'PRTRMaterialeEx'
	exec sp_refreshview 'PRTRAttivitaEx'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 45, getdate())
	print '0.0045 fine script'

end 
go 
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0045 begin

	print '0.0046 inizio script'

	exec asp_du_AddAlterColumn 'xMORL'	, 'Colli'					, 'int not null'			, '0'	, 'Colli del documento'
	exec asp_du_AddAlterColumn 'xMORL'	, 'PesoLordo'				, 'numeric(18,8) not null'	, '0'	, 'Peso lordo in Kg '
	exec asp_du_AddAlterColumn 'xMORL'	, 'PesoNetto'				, 'numeric(18,8) not null'	, '0'	, 'Peso netto in kg'
	exec asp_du_AddAlterColumn 'xMORL'	, 'VolumeTotale'			, 'numeric(18,8) not null'	, '0'	, 'Volume in m3'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoVettore_1'			, 'char(2) null'			, ''	, 'Codice Cd_DoVettore_1'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Vettore1DataOra'			, 'datetime null'			, ''	, 'Data Vettore 1'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoVettore_2'			, 'char(2) null'			, ''	, 'Codice Cd_DoVettore_2'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Vettore2DataOra'			, 'datetime null'			, ''	, 'Data Vettore 2'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoTrasporto'			,  'char(3) null'			, ''	, 'Trasporto'
	exec asp_du_AddAlterColumn 'xMORL'	, 'TrasportoDataora'		,  'smalldatetime null'		, ''	, 'Dato ora Trasporto'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoSped'				,  'char(3) null'			, ''	, 'Spedizione'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoPorto'				,  'char(3) null'			, ''	, 'Porto'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoAspBene'			,  'char(3) null'			, ''	, 'Aspetto beni'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoCommittente'		,  'char(3) null'			, ''	, 'Committente'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoProprietarioMerce'	,  'char(3) null'			, ''	, 'Proprietario merce'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoLuogoCarico'		,  'char(3) null'			, ''	, 'Luogo di carico'
	exec asp_du_AddAlterColumn 'xMORL'	, 'Cd_DoLuogoScarico'		,  'char(3) null'			, ''	, 'Luogo di carico'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 46, getdate())
	print '0.0046 fine script'
end 
go 

declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0046 begin

	print '0.0047 inizio script'

	-- Aggiunge il controllo per
	if not exists(select * from xMOControllo where Cd_xMOControllo = 'COM/PREL/EXISTS')
		insert into xMOControllo (Cd_xMOControllo, Descrizione, Attivo) values ('COM/PREL/EXISTS', 'Sottocommessa per l''articolo corrente non presente nei prelievi.', 1)

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 47, getdate())
	print '0.0047 fine script'
end 
go 


declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc) 
-- upgrade da versione 
if cast(@CurrVer as numeric(18, 4)) = 0.0047 begin

	print '0.0048 inizio script'

	-- incremento versione 
	insert into xMOVersion (DBVer, DBBuild, DBRevi, UpdDate) values (0, 0, 48, getdate())
	print '0.0048 fine script'
end 
go 


--				/\/\/\/\/\/\/\/\/\ 
-- -------------------------------------------------------------
--		#3		da eseguire sempre al termine dello script
-- -------------------------------------------------------------
-- -------------------------------------------------------------
--		#3.1	aggiunge i check constraint
-- -------------------------------------------------------------

alter table xMOINRig			with nocheck add constraint CK_xMOINRig_QtaRilevata	check (QtaRilevata IS NULL OR ([QtaRilevata]>=0))		
alter table DO					with nocheck add constraint xCK_DO_xMOResiduoInPrelievo check (xMOResiduoInPrelievo = 0 OR (xMOResiduoInPrelievo >= 1 AND xMOPrelievo = 1))
alter table DO					with nocheck add constraint xCK_DO_TipoDocumento check (xMOAttivo = 0 OR (xMOAttivo = 1 AND isnull(xCd_xMOProgramma, '') <> '' AND (TipoDocumento='B' OR TipoDocumento='M' OR TipoDocumento='D' OR TipoDocumento='G' OR TipoDocumento='V' OR TipoDocumento='T' OR TipoDocumento='R' OR TipoDocumento='O' OR TipoDocumento='P' OR TipoDocumento='L')))
alter table MGUbicazione		with nocheck add constraint xCK_MGUbicazione_xMOStato check (xMOStato = 'A' OR xMOStato = 'D' OR xMOStato = 'B')
alter table MGUbicazione		with nocheck add constraint xCK_MGUbicazione_xMOTipo check (xMOTipo = 'S' OR xMOTipo = 'P')
alter table MGUbicazione		with nocheck add constraint xCK_MGUbicazione_AssegnazioneACorsia check ((xCd_xMOMGCorsia is not null And xMORiga is not null And xMOColonna is not null) Or (xCd_xMOMGCorsia is null And xMORiga is null And xMOColonna is null))
go

alter table xMOINRig			check constraint CK_xMOINRig_QtaRilevata 
alter table DO					check constraint xCK_DO_xMOResiduoInPrelievo
alter table DO					check constraint xCK_DO_TipoDocumento
alter table MGUbicazione		check constraint xCK_MGUbicazione_xMOStato
alter table MGUbicazione		check constraint xCK_MGUbicazione_xMOTipo
alter table MGUbicazione		check constraint xCK_MGUbicazione_AssegnazioneACorsia
go

-- -------------------------------------------------------------
--		#3.2	aggiunge gli indici
-- -------------------------------------------------------------
create unique	nonclustered index UK_xMOTerminale_Terminale					on xMOTerminale			(Terminale)
create unique	nonclustered index UK_xMORLPrelievo_Id_xMORL_Id_DOTes_Id_DORig	on xMORLPrelievo		(Id_xMORL, Id_DOTes, Id_DORig)
create unique	nonclustered index UK_xMOListener_IP_ListenPort_Attivo			on xMOListener			(IP, ListenPort, Attivo)
create unique	nonclustered index UK_xMOMatGiac_Matricola_Cd_Ar_Cd_ArLotto		on xMOMatGiac			(Matricola, Cd_Ar, Cd_ArLotto)
go
-- -------------------------------------------------------------
--		#3.3		aggiunge le foreign key
-- -------------------------------------------------------------

alter table DO					with nocheck add constraint xFK_DO_CF						foreign key (xMOCd_CF)						references CF (Cd_CF)																			not for replication
alter table DO					with nocheck add constraint xFK_DO_CFDest					foreign key (xMOCd_CF, xMOCd_CFDest)		references CFDest (Cd_CF, Cd_CFDest)															not for replication 	
alter table DO					with nocheck add constraint xFk_DO_xMOProgramma				foreign key (xCd_xMOProgramma)				references xMOProgramma (Cd_xMOProgramma)														not for replication 	

--DEPRECATI nella versione 0.0004 (la tabella è stata eliminata)
--alter table xMODOControllo		with nocheck add constraint FK_xMODOControllo_DO			foreign key (Cd_DO)							references DO (Cd_DO)																			not for replication
--alter table xMODOControllo		with nocheck add constraint FK_xMODOControllo_xMOControllo	foreign key (Cd_xMOControllo)				references xMOControllo (Cd_xMOControllo)														not for replication

alter table Operatore			with nocheck add constraint xFK_Operatore_Mg				foreign key (xMOCd_MG)						references MG (Cd_MG)																			not for replication

alter table xMOListenerDevice	with nocheck add constraint FK_xMOListenerDevice_xMOListener	foreign key (Cd_xMOListener)			references xMOListener (Cd_xMOListener)			on delete cascade		on update cascade		not for replication
alter table xMOListenerCoda		with nocheck add constraint FK_xMOListenerCoda_xMOListener	foreign key (Cd_xMOListener)				references xMOListener (Cd_xMOListener)															not for replication
alter table xMOTerminale		with nocheck add constraint FK_xMOTerminale_xMOListener		foreign key (Cd_xMOListener)				references xMOListener (Cd_xMOListener)															not for replication

alter table xMOMatricola		with nocheck add constraint FK_xMOMatricola_xMOLinea		foreign key (Cd_xMOLinea)					references xMOLinea (Cd_xMOLinea)																not for replication
alter table xMOMatricola		with nocheck add constraint FK_xMOMatricola_AR				foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication
alter table xMOMatricola		with nocheck add constraint FK_xMOMatricola_DORig			foreign key (Id_DORig)						references DORig (Id_DORig)						on delete set null		ON UPDATE NO ACTION		not for replication
-- Impossibile la FK perché il lotto deve ancora essere creato in Arca!!! alter table xMOMatricola		with nocheck add constraint FK_xMOMatricola_ARLotto		foreign key (Cd_AR,Cd_ARLotto)				references ARLotto (Cd_AR, Cd_ARLotto)															not for replication
-- ### DA FARE (in arca alla cancellazione di un doc va fatto l'update dell'id per permetterne l'eliminazione!!)

alter table xMOConsumo			with nocheck add constraint FK_xMOConsumo_xMOLinea			foreign key (Cd_xMOLinea)					references xMOLinea (Cd_xMOLinea)																not for replication
alter table xMOConsumo			with nocheck add constraint FK_xMOConsumo_AR				foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication

alter table xMORL				with nocheck add constraint FK_xMORL_DO						foreign key (Cd_DO)							references DO (Cd_DO)																			not for replication	
alter table xMORL				with nocheck add constraint FK_xMORL_Operatore				foreign key (Cd_Operatore)					references Operatore(Cd_Operatore)																not for replication
alter table xMORL				with nocheck add constraint FK_xMORL_CF						foreign key (Cd_CF)							references CF(Cd_CF)																			not for replication 
alter table xMORL				with nocheck add constraint FK_xMORL_CFDest					foreign key (Cd_CF, Cd_CFDest)				references CFDest (Cd_CF, Cd_CFDest)															not for replication	
alter table xMORL				with nocheck add constraint FK_xMORL_xMOLinea				foreign key (Cd_xMOLinea)					references xMOLinea (Cd_xMOLinea)																not for replication 
alter table xMORL				with nocheck add constraint FK_xMORL_MG_P					foreign key (Cd_MG_P)						references MG (Cd_MG)																			not for replication
alter table xMORL				with nocheck add constraint FK_xMORL_MG_A					foreign key (Cd_MG_A)						references MG (Cd_MG)																			not for replication
alter table xMORL				with nocheck add constraint FK_xMORL_DoSdTAnag				foreign key (Cd_DOCaricatore)				references DoSdTAnag (Cd_DoSdTAnag)																not for replication
alter table xMORL				with nocheck add constraint FK_xMORL_DOTes					foreign key (Id_DOTes)						references DOTes (Id_DOTes)						on delete set null	 	on update no action		not for replication

alter table xMORLPackListRef	with nocheck add constraint FK_xMORLPackListRef_xMORL		foreign key (Id_xMORL)						references xMORL (Id_xMORL)						on delete cascade		on update cascade		not for replication
alter table xMORLPackListRef	with nocheck add constraint FK_xMORLPackListRef_xMOUniLog	foreign key (Cd_xMOUniLog)					references xMOUniLog (Cd_xMOUniLog)																not for replication

alter table xMORLRig			with nocheck add constraint FK_xMORLRig_xMORL				foreign key (Id_xMORL)						references xMORL (Id_xMORL)						on delete cascade		on update cascade		not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_AR					foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_MG_P				foreign key (Cd_MG_P)						references MG (Cd_MG)																			not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_xMORL_P				foreign key (Cd_MG_P,Cd_MGUbicazione_P)		references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_MG_A				foreign key (Cd_MG_A)						references MG (Cd_MG)																			not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_xMORL_A				foreign key (Cd_MG_A,Cd_MGUbicazione_A)		references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication
-- Impossibile la FK perché il lotto deve ancora essere creato in Arca!!! alter table xMORLRig			with nocheck add constraint FK_xMORLRig_ARLotto				foreign key (Cd_AR, Cd_ARLotto)				references ARLotto (Cd_AR, Cd_ARLotto)															not for replication
alter table xMORLRig			with nocheck add constraint FK_xMORLRig_ARMisura			foreign key (Cd_ARMisura)					references ARMisura (Cd_ARMisura)																not for replication

alter table xMORLRigPackList	with nocheck add constraint FK_xMORLRigPackList_xMORLRig	foreign key (Id_xMORLRig)					references xMORLRig (Id_xMORLRig)				on delete cascade		on update cascade		not for replication

alter table xMORLPrelievo		with nocheck add constraint FK_xMORLPrelievo_xMORL			foreign key (Id_xMORL)						references xMORL (Id_xMORL)						on delete cascade		on update cascade		not for replication
--alter table xMORLPrelievo		with nocheck add constraint FK_xMORLPrelievo_DOTes			foreign key (Id_DOTes)						references DOTes (Id_DOTes)																		not for replication
--alter table xMORLPrelievo		with nocheck add constraint FK_xMORLPrelievo_DORig			foreign key (Id_DORig)						references DORig (Id_DORig)																		not for replication

alter table xMOTR				with nocheck add constraint FK_xMOTR_MG_A					foreign key (Cd_MG_A)						references MG (Cd_MG)																			not for replication
alter table xMOTR				with nocheck add constraint FK_xMOTR_MGUbicazione_A			foreign key (Cd_MG_A, Cd_MGUbicazione_A)	references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication
alter table xMOTR				with nocheck add constraint FK_xMOTR_MG_P					foreign key (Cd_MG_P)						references MG (Cd_MG)																			not for replication
alter table xMOTR				with nocheck add constraint FK_xMOTR_xMORL_P				foreign key (Cd_MG_P, Cd_MGUbicazione_P)	references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication
alter table xMOTR				with nocheck add constraint FK_xMOTR_Operatore				foreign key (Cd_Operatore)					references Operatore (Cd_Operatore)																not for replication

alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_xMOTR				foreign key (Id_xMOTR)						references xMOTR (Id_xMOTR)						on delete cascade		on update cascade		not for replication
alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_ARMisura			foreign key (Cd_ARMisura)					references ARMisura (Cd_ARMisura)																not for replication
alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_MG_A				foreign key (Cd_MG_A)						references MG (Cd_MG)																			not for replication
alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_xMORL_A			foreign key (Cd_MG_A, Cd_MGUbicazione_A)	references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication
alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_MGMovInt			foreign key (Id_MGMovInt)					references MGMovInt (Id_MGMovInt)																not for replication
alter table xMOTRRig_A			with nocheck add constraint Fk_xMOTRRig_A_xMOTRRig_P		foreign key (Id_xMOTRRig_P)					references xMOTRRig_P (Id_xMOTRRig_P)															not for replication

alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_xMOTR				foreign key (Id_xMOTR)						references xMOTR (Id_xMOTR)						on delete cascade		on update cascade		not for replication
alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_AR				foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication
alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_ARLotto			foreign key (Cd_AR, Cd_ARLotto)				references ARLotto (Cd_AR,Cd_ARLotto)															not for replication
alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_ARMisura			foreign key (Cd_ARMisura)					references ARMisura (Cd_ARMisura)																not for replication
alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_MG_P				foreign key (Cd_MG_P)						references MG (Cd_MG)																			not for replication
alter table xMOTRRig_P			with nocheck add constraint Fk_xMOTRRig_P_MGUbicazione_P	foreign key (Cd_MG_P, Cd_MGUbicazione_P)	references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication	

alter table xMOTRRig_T			with nocheck add constraint Fk_xMOTRRig_T_xMOTR				foreign key (Id_xMOTR)						references xMOTR (Id_xMOTR)						on delete cascade		on update cascade		not for replication
alter table xMOTRRig_T			with nocheck add constraint Fk_xMOTRRig_T_xMOTRRig_P		foreign key (Id_xMOTRRig_P)					references xMOTRRig_P (Id_xMOTRRig_P)															not for replication
alter table xMOTRRig_T			with nocheck add constraint Fk_xMOTRRig_T_MG_A				foreign key (Cd_MG_A)						references MG (Cd_MG)																			not for replication
alter table xMOTRRig_T			with nocheck add constraint Fk_xMOTRRig_T_MGUbicazione_A	foreign key (Cd_MG_A, Cd_MGUbicazione_A)	references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication	

alter table xMOBCCampo			with nocheck add constraint Fk_xMOBCCampo_Cd_xMOBC			foreign key (Cd_xMOBC)						references xMOBC (Cd_xMOBC)						on delete cascade								not for replication	

-- foreign key tabelle xMOIN e xMOINRig 
alter table xMOIN				with nocheck add constraint FK_xMOIN_Operatore				foreign key (Cd_Operatore)					references Operatore(Cd_Operatore)																not for replication
alter table xMOIN				with nocheck add constraint FK_xMOIN_MGEsercizio			foreign key (Cd_MGEsercizio)				references MGEsercizio (Cd_MGEsercizio)															not for replication
alter table xMOIN				with nocheck add constraint FK_xMOIN_MG						foreign key (Cd_MG)							references MG (Cd_MG)																			not for replication
alter table xMOIN				with nocheck add constraint FK_xMOIN_MGUbicazione			foreign key (Cd_MG, Cd_MGUbicazione)		references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication

alter table xMOINRig			with nocheck add constraint FK_xMOINRig_xMOIN				foreign key (Id_xMOIN)						references xMOIN (Id_xMOIN)						on delete cascade		on update cascade		not for replication
alter table xMOINRig			with nocheck add constraint FK_xMOINRig_Cd_AR				foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication
alter table xMOINRig			with nocheck add constraint Fk_xMOINRig_ARMisura			foreign key (Cd_ARMisura)					references ARMisura (Cd_ARMisura)																not for replication
alter table xMOINRig			with nocheck add constraint Fk_xMOINRig_DOSottoCommessa		foreign key (Cd_DOSottoCommessa)			references DOSottoCommessa (Cd_DOSottoCommessa)													not for replication
alter table xMOINRig			with nocheck add constraint Fk_xMOINRig_ARLotto				foreign key (Cd_AR, Cd_ARLotto)				references ARLotto (Cd_AR,Cd_ARLotto)															not for replication
alter table xMOINRig			with nocheck add constraint FK_xMOINRig_MG					foreign key (Cd_MG)							references MG (Cd_MG)																			not for replication
alter table xMOINRig			with nocheck add constraint FK_xMOINRig_MGUbicazione		foreign key (Cd_MG, Cd_MGUbicazione)		references MGUbicazione (Cd_MG, Cd_MGUbicazione)												not for replication

alter table xMOMGCorsia			with nocheck add constraint FK_xMOMGCorsia_MG				foreign key (Cd_MG)							references MG (Cd_MG)							on delete cascade								not for replication

alter table MGUbicazione		with nocheck add constraint xFK_MGUbicazione_xMOMGCorsia	foreign key (Cd_MG, xCd_xMOMGCorsia)		references xMOMGCorsia (Cd_MG, Cd_xMOMGCorsia)													not for replication

alter table xMOPRTR				with nocheck add constraint FK_xMOPRTR_Operatore			foreign key (Cd_Operatore)					references Operatore (Cd_Operatore)																not for replication
alter table xMOPRTR				with nocheck add constraint FK_xMOPRTR_PRTRAttivita			foreign key (Id_PRTRAttivita)				references PRTRAttivita (Id_PRTRAttivita)		on delete set null								not for replication

alter table xMOPRTRRig			with nocheck add constraint FK_xMOPRTRRig_xMOPRTR			foreign key (Id_xMOPRTR)					references xMOPRTR (Id_xMOPRTR)					on delete cascade		on update cascade		not for replication
alter table xMOPRTRRig			with nocheck add constraint FK_xMOPRTRRig_Cd_AR				foreign key (Cd_AR)							references AR (Cd_AR)																			not for replication
alter table xMOPRTRRig			with nocheck add constraint Fk_xMOPRTRRig_ARMisura			foreign key (Cd_ARMisura)					references ARMisura (Cd_ARMisura)																not for replication
alter table xMOPRTRRig			with nocheck add constraint Fk_xMOPRTRRig_ARLotto			foreign key (Cd_AR, Cd_ARLotto)				references ARLotto (Cd_AR,Cd_ARLotto)															not for replication


go

--- /
alter table DO					check constraint xFK_DO_CF						
alter table DO					check constraint xFK_DO_CFDest					
alter table DO					check constraint xFk_DO_xMOProgramma

--DEPRECATI nella versione 0.0004 (la tabella è stata eliminata)
--alter table xMODOControllo		check constraint FK_xMODOControllo_DO			
--alter table xMODOControllo		check constraint FK_xMODOControllo_xMOControllo	

alter table Operatore			check constraint xFK_Operatore_Mg				

alter table xMOListenerCoda		check constraint FK_xMOListenerCoda_xMOListener	
alter table xMOTerminale		check constraint FK_xMOTerminale_xMOListener		

alter table xMOMatricola		check constraint FK_xMOMatricola_xMOLinea		
alter table xMOMatricola		check constraint FK_xMOMatricola_AR			
--alter table xMOMatricola		check constraint FK_xMOMatricola_ARLotto		

alter table xMOConsumo			check constraint FK_xMOConsumo_xMOLinea		
alter table xMOConsumo			check constraint FK_xMOConsumo_AR			

alter table xMORL				check constraint FK_xMORL_DO						
alter table xMORL				check constraint FK_xMORL_Operatore				
alter table xMORL				check constraint FK_xMORL_CF						
alter table xMORL				check constraint FK_xMORL_CFDest					
alter table xMORL				check constraint FK_xMORL_xMOLinea				
alter table xMORL				check constraint FK_xMORL_MG_P					
alter table xMORL				check constraint FK_xMORL_MG_A					

alter table xMORLPackListRef	check constraint FK_xMORLPackListRef_xMORL
alter table xMORLPackListRef	check constraint FK_xMORLPackListRef_xMOUniLog

alter table xMORLRig			check constraint FK_xMORLRig_xMORL				
alter table xMORLRig			check constraint FK_xMORLRig_AR					
alter table xMORLRig			check constraint FK_xMORLRig_MG_P				
alter table xMORLRig			check constraint FK_xMORLRig_xMORL_P				
alter table xMORLRig			check constraint FK_xMORLRig_MG_A				
alter table xMORLRig			check constraint FK_xMORLRig_xMORL_A				

-- alter table xMORLRig			check constraint FK_xMORLRig_ARLotto				
alter table xMORLRig			check constraint FK_xMORLRig_ARMisura	

alter table xMORLRigPackList	check constraint FK_xMORLRigPackList_xMORLRig		

alter table xMORLPrelievo		check constraint FK_xMORLPrelievo_xMORL
--alter table xMORLPrelievo		check constraint FK_xMORLPrelievo_DOTes
--alter table xMORLPrelievo		check constraint FK_xMORLPrelievo_DORig

alter table xMOTR				check constraint FK_xMOTR_MG_A				
alter table xMOTR				check constraint FK_xMOTR_MGUbicazione_A				
alter table xMOTR				check constraint FK_xMOTR_MG_P				
alter table xMOTR				check constraint FK_xMOTR_xMORL_P				
alter table xMOTR				check constraint FK_xMOTR_Operatore			

alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_xMOTR	
alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_ARMisura	
alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_MG_A		
alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_xMORL_A	
alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_MGMovInt	
alter table xMOTRRig_A			check constraint Fk_xMOTRRig_A_xMOTRRig_P
								
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_xMOTR	
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_AR		
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_ARLotto	
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_ARMisura	
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_MG_P		
alter table xMOTRRig_P			check constraint Fk_xMOTRRig_P_MGUbicazione_P	

alter table xMOTRRig_T			check constraint Fk_xMOTRRig_T_xMOTR			
alter table xMOTRRig_T			check constraint Fk_xMOTRRig_T_MG_A			
alter table xMOTRRig_T			check constraint Fk_xMOTRRig_T_MGUbicazione_A
alter table xMOTRRig_T			check constraint Fk_xMOTRRig_T_xMOTRRig_P
		
alter table xMOBCCampo			check constraint Fk_xMOBCCampo_Cd_xMOBC

alter table xMOMGCorsia			check constraint FK_xMOMGCorsia_MG

alter table MGUbicazione		check constraint xFK_MGUbicazione_xMOMGCorsia

alter table xMOPRTR				check constraint FK_xMOPRTR_Operatore	
alter table xMOPRTR				check constraint FK_xMOPRTR_PRTRAttivita

alter table xMOPRTRRig			check constraint FK_xMOPRTRRig_xMOPRTR		
alter table xMOPRTRRig			check constraint FK_xMOPRTRRig_Cd_AR		
alter table xMOPRTRRig			check constraint Fk_xMOPRTRRig_ARMisura	
alter table xMOPRTRRig			check constraint Fk_xMOPRTRRig_ARLotto		

go

-- -------------------------------------------------------------
--		#3.4		gestione delle funzioni 
-- -------------------------------------------------------------

-- -------------------------------------------------------------
--		#3.4.1		aggiunge le viste necessarie alle funzioni 
-- -------------------------------------------------------------

-- Elenco dei documenti gestiti dagli operatori
create view xmovs_DOOperatore 
as (
	select 
		Cd_DO			= OperatoreDO.Cd_DO, 
		Cd_Operatore	= Operatore.Cd_Operatore
	from 
		OperatoreDO inner join Operatore On OperatoreDO.Id_Operatore = Operatore.Id_Operatore
	union
	select 
		Cd_DO			= DO.Cd_DO,
		Cd_Operatore	= Operatore.Cd_Operatore
	from 
		Operatore, DO
	where 
		Id_Operatore not in (select Id_Operatore from OperatoreDO)
)
go

-- Elenco dei documenti gestiti dagli operatori
create view xmovs_UniLogOperatore 
as (
	Select
		xMOUniLog.Cd_xMOUniLog
		, Cd_Operatore = IsNull(o.value('@cd_operatore', 'varchar(20)'), '') 
	From 
		xMOUniLog 
			Cross Apply Operatori.nodes('rows/row') AS x(o) 
	union
	Select
		xMOUniLog.Cd_xMOUniLog
		, Operatore.Cd_Operatore
	From 
		xMOUniLog, Operatore
	where
			Operatori is null
)
go

create view xmovs_xMOListenerOperatore 
as (
	-- Listener con operatori
	Select
		xMOListener.Cd_xMOListener,
		Cd_Operatore = IsNull(o.value('@cd_operatore', 'varchar(39)'), '') 
	From 
		xMOListener 
			Cross Apply Operatori.nodes('rows/row') AS x(o) 
	union 
	-- Listener tutti operatori
	Select
		xMOListener.Cd_xMOListener,
		Operatore.Cd_Operatore 
	From 
		xMOListener, Operatore
	where
		isnull(cast(Operatori as varchar(max)), '') = ''
)
go

-- Elenco dei documenti gestiti dai terminali
create view xmovs_DOTerminale 
as (
	Select
		DO.Cd_DO,
		Terminale = IsNull(o.value('@cd_xmoterminale', 'varchar(39)'), '') 
	From 
		DO 
			Cross Apply xMOTerminali.nodes('rows/row') AS x(o) 
	where
		xMOAttivo = 1
	union
	Select
		DO.Cd_DO,
		xMOTerminale.Terminale 
	From 
		DO, xMOTerminale
	where
			xMOTerminali is null
		And DO.xMOAttivo = 1	
)
go

-- Elenco delle unità logistiche gestite dai terminali
create view xmovs_UniLogTerminale 
as (
	Select
		xMOUniLog.Cd_xMOUniLog
		, Terminale = IsNull(o.value('@cd_xmoterminale', 'varchar(39)'), '') 
	From 
		xMOUniLog 
			Cross Apply Terminali.nodes('rows/row') AS x(o) 
	union
	Select
		xMOUniLog.Cd_xMOUniLog
		, xMOTerminale.Terminale 
	From 
		xMOUniLog, xMOTerminale
	where
			Terminali is null
)
go

-- Elenco dei controlli abilitati per terminale
create view xmovs_DOxMOControlli
as (
	Select 
		c.*
		, xMOControllo.Descrizione 			
	from 
		xMOControllo inner join 
		(
			Select
				DO.Cd_DO,
				Cd_xMOControllo = IsNull(o.value('@cd_xmocontrollo', 'varchar(20)'), '') 
			From 
				DO 
					Cross Apply xMOControlli.nodes('rows/row') AS x(o) 
		) c on xMOControllo.Cd_xMOControllo = c.Cd_xMOControllo
	where
		xMOControllo.Attivo = 1
)
go



-- -------------------------------------------------------------
--		#3.4.2		aggiunge le funzioni 
-- -------------------------------------------------------------

create function xmofn_AR_Descrizione(  -- Alex
	@Cd_AR varchar(20) = null
) returns varchar(80)
as begin
	if @Cd_AR is null
		return ''
	declare @retval varchar(80)
	SELECT @retval = Descrizione FROM AR where Cd_AR = @Cd_AR;
	return @retval
end
go


create function xmofn_StatoGiac (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Cd_MG char(5)
	, @Cd_MGUbicazione varchar(20)
	, @Cd_AR varchar(20) = null
) returns smallint 
as begin

	declare @giac numeric(18, 8)
	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())
	-- Seleziona tutta la giacenza dell'ubicazione, se passato, solo dell'articolo
	set @giac = isnull((select sum(Quantita) from dbo.MGGiacEx(@Cd_MGEsercizio) where Cd_MG = @Cd_MG And isnull(Cd_MGUbicazione, '') = isnull(@Cd_MGUbicazione, '') And Quantita > 0 And (@Cd_AR is null Or Cd_AR = @Cd_AR)), 0)
	
	-- Restituisce lo stato di una ubicazione
	return case 
		when @giac = 0 then 0	-- Vuota --> 0
		else 1					-- Con giacenza --> 1
		end 
	-- Negativa --> 2 ### da sviluppare

end
go

Create Function xmofn_Ids_Split (
	@Ids varchar(max)
)
Returns @out Table (Id int)
As
Begin
	--Separatore degli Id nella stringa
	Declare @delimiter Char(1) = ','

	Declare @start Int, @end Int

	Select @start = 1, @end = CHARINDEX(@delimiter, @Ids) 
	While @start < LEN(@Ids) + 1 Begin
		If @end = 0
			Set @end = LEN(@Ids) + 1
			    
		Insert Into @out
		Select SUBSTRING(@Ids, @start, @end - @start)

		Set @start = @end + 1 
		Set @end = CHARINDEX(@delimiter, @Ids, @start)
	End

	return
End
Go

-- Restituisce lo stato della testa dell''inventario (0 = in compilazione; 1 = Inventariato; 2 = Annullato)'
create function xmofn_xMOIN_Stato(
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)

	select
		@descrizione =
		case @Stato 				-- Stato della testa dell''inventario
			when 0 then 'In compilazione'
			when 1 then 'Da storicizzare'
			when 2 then 'Storicizzato'
			when 3 then 'Annullato'
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce lo stato del trasferimento (0 = In corso; 1 = Trasferito in Arca; 2 = Annullato;)
create function xmofn_xMOTR_Stato(
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)

	select
		@descrizione =
		case @Stato 				-- Stato della testa del trasferimento 
			when 0 then 'In compilazione'
			when 1 then 'Da storicizzare'
			when 2 then 'Storicizzato'
			when 3 then 'Annullato'
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce lo stato della testa della rilevazione
create function xmofn_xMORL_Stato(
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)

	select
		@descrizione =
		case @Stato 				-- Stato della testa del documento 
			when 0 then 'In compilazione'
			when 1 then 'Da storicizzare'
			when 2 then 'Storicizzata in Arca' -- (Id_DOTes not null)
			when 3 then 'Annullata'
			when 4 then 'Creata Manualmente in Arca'
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce lo stato del record del consumo (0 inserito dall''operatore, 1 completamente utilizzato, <0 errore)'
create function xmofn_xMOConsumo_Stato (
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)
	select
		@descrizione =
		case  			
			when @Stato < 0	then 'Errore'
			when @Stato = 0	then 'Inserito dall''operatore'
			when @Stato = 1	then 'Consumato' -- completamente utilizzato
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce lo stato del record della matricola 
create function xmofn_xMOMatricola_Stato(
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)

	select
		@descrizione =
		case  			
			when @Stato < -1	then 'Errore di import'
			when @Stato = -1	then 'Annullato'
			when @Stato = 0		then 'Da importare'
			when @Stato = 1		then 'Storicizzata'
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce lo stato della coda di comandi da processare con il listener
create function xmofn_xMOListenerCoda_Stato(
	@Stato smallint
) returns varchar(30)
/*ENCRYPTED*/
as begin
	declare @descrizione varchar(30)

	select
		@descrizione =
		case @Stato 				
			when 0 then 'Da prendere in carico'
			when 1 then 'Eseguito'
			when 2 then 'Annullato' 
			when 3 then 'Errore'
			else 'ERR-UNKNOW'
		end
	return @descrizione
end
go

-- Restituisce le info di xMORL
create function xmofn_xMORL_Info(
	@Id_xMORL int
) returns varchar(100)
/*ENCRYPTED*/
as begin 
	declare @r varchar(100)
	select
		@r = Cd_DO + ' [' + ltrim(rtrim(str(@Id_xMORL))) + '] Op. ' + ltrim(rtrim(Cd_Operatore)) + ' da ' + ltrim(rtrim(Terminale)) 
	from
		xMORL
	where
		Id_xMORL = @Id_xMORL

	return isnull(@r, 'Impossibile recuperare le informazioni relative al xMORL ' + ltrim(rtrim(str(@Id_xMORL))))
end
go

-- Restituisce l'Id della testa che blocca il prelievo
create function xmofn_xMORLPrelievo_Test (
	@Id_xMORL		int
	, @Id_DOTess	varchar(max)
) returns int 
/*ENCRYPTED*/
as begin 
	
	declare @Id_xMORL_Blocca	int

	-- La stringa dei prelievi deve iniziare e finire con "," e non deve contenere spazi!
	set @Id_DOTess = 
					case when left(@Id_DOTess, 1) <> ',' then ',' else '' end		-- Virgola iniziale
					+ replace(@Id_DOTess, ' ', '')									-- elimina gli spazi
					+ case when right(@Id_DOTess, 1) <> ',' then ',' else '' end	-- Virgola finale


	-- Seleziono il primo record valido che blocca il prelievo
	set @Id_xMORL_Blocca = (select top 1
								rl.Id_xMORL 
							from 
								xMORLPrelievo			rlp 
									inner join xMORL	rl		on rl.Id_xMORL = rlp.Id_xMORL
							where  
									rl.Id_xMORL <> @Id_xMORL				-- Documento corrente da escludere del test
								And rl.Stato = 0							-- Documento in compilazione
								And rlp.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))
							)
	-- restituisce l'id della rl della riga uguale a quella passata
	return Isnull(@Id_xMORL_Blocca, 0)

end 
go

-- Restituisce il Cd_AR di un Alias o Codice Alternativo passato alla funzione
create function xmofn_Get_AR_From_AAA(
	@Cd_AR varchar(30) 
	, @Cd_CF varchar(30) 
) returns varchar(20)
/*ENCRYPTED*/
as begin 
	declare @sel as table (Ordine	int, Cd_AR varchar(20))

	Insert into @sel (Ordine, Cd_AR)
			Select 1, ARCodCF.Cd_AR		From ARCodCF	Where CodiceAlternativo = @Cd_AR And Cd_CF = @Cd_CF
	union	Select 2, ARAlias.CD_AR		From ARAlias	Where Alias = @Cd_AR
	union	Select 3, CD_AR				From AR			Where CD_AR = @Cd_AR

	return (select top 1 Cd_Ar from @sel order by Ordine)
end 
go

-- Il documento deve poter essere attivo e gestibile dall'operatore e/o dal terminale
create function dbo.xmofn_DO (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
) returns table 
/*ENCRYPTED*/
as return (

	select
		Ordinamento				= ROW_NUMBER() over (order by Cd_DO)
		, Cd_DO					= DO.Cd_DO
		, DO_Descrizione		= DO.Descrizione
		, TipoDocumento			= DO.TipoDocumento
		, CliFor				= DO.CliFor
		, Ciclo					= Case	When CliFor = 'C'											Then 'ca' 
										When CliFor = 'F' And TipoDocumento IN('L', 'R', 'V', 'T')	Then 'ad'
										Else															 'cp'
									End
		-- Tipologia di AR Misura da proporre (acquisto o vendita)
		, TipoARMisura			= Case	When CliFor = 'C'											Then 'V' 
										When CliFor = 'F' And TipoDocumento IN('L', 'R', 'V', 'T')	Then ''
										Else															 'A'
									End
		-- Causale di magazzino
		, Cd_MGCausale			= MGCausale.Cd_MGCausale
		, MGC_Descrizione		= MGCausale.Descrizione
		-- Magazzino di partenza
		, MagPFlag				= MGCausale.MagPFlag		-- Vero se il magazzino di partenza è attivo 
		, Cd_MG_P				= MGCausale.Cd_MG_P			-- Magazzino di partenza (se vuoto in moovi va specificato)
		, MGP_Descrizione		= mg_p.Descrizione
		, UIMagPFix				= MGCausale.UIMagPFix		-- Magazzino FISSO (se vero il magazzino non è modificabile)
		, MGP_UbicazioneObbligatoria = mg_p.MG_UbicazioneObbligatoria 
		-- Magazzino di arrivo
		, MagAFlag				= MGCausale.MagAFlag		-- Vero se il magazzino di arrivo è attivo
		, Cd_MG_A				= MGCausale.Cd_MG_A			-- Magazzino di arrivo (se vuoto in moovi va specificato)
		, MGA_Descrizione		= mg_a.Descrizione
		, UIMagAFix				= MGCausale.UIMagAFix		-- Magazzino FISSO (se vero il magazzino non è modificabile)
		, MGA_UbicazioneObbligatoria = mg_a.MG_UbicazioneObbligatoria 
		-- Gestione del lotto
		, ARLottoAuto			= DO.ARLottoAuto			-- Se 0 non è possibile creare il lotto; > 0 
		-- Numero Moduli definiti per il documento
		, Moduli				= (Select COUNT(*) from DOReport inner join ReportDocAll on DOReport.UD_ReportDoc = ReportDocAll.Ud_ReportDoc where DOReport.Cd_DO = DO.Cd_DO)
		-- Matricola abilitata
		, MtrEnabled			= DO.MtrEnabled
		-- Packing List abilitata
		, PkLstEnabled			= DO.PkLstEnabled
		, PkLstInputMask		= DO.PkLstInputMask
		-- , xMOAttivo			= DO.xMOAttivo
		, xMOCd_CF				= DO.xMOCd_CF
		--, xMOCF_Descrizione		= case when DO.xMOCd_CF is null then '' else (Select Descrizione From CF Where Cd_CF = DO.xMOCd_CF) end
		, xMOCF_Descrizione		= (Select top 1 Descrizione From CF Where Cd_CF = DO.xMOCd_CF)
		, xMOCd_CFDest			= DO.xMOCd_CFDest
		--, xMOCFDest_Descrizione	= case when DO.xMOCd_CFDest is null then '' else (Select Descrizione From CFDest Where Cd_CFDest = DO.xMOCd_CFDest) end
		, xMOCFDest_Descrizione	= (Select top 1 Descrizione From CFDest Where Cd_CFDest = DO.xMOCd_CFDest)
		, xMOPrelievo			= DO.xMOPrelievo			
		, xMOPrelievoObb		= DO.xMOPrelievoObb
		, xMOTipoPrelievo		= case when DO.xMOPrelievo > 0 then case when DO.xMOPrelievoObb = 0 then 1 else 2 end else 0 end
		, xMOFuoriLista			= DO.xMOFuoriLista	
		, xMOResiduoInPrelievo  = DO.xMOResiduoInPrelievo 	
		, xMOUmDef				= DO.xMOUmDef
		, xMOUMFatt				= DO.xMOUMFatt
		, xMOLinea				= DO.xMOLinea			
		, xMOLotto				= DO.xMOLotto			
		, xMOUbicazione			= DO.xMOUbicazione			
		--, xMOControlli			= DO.xMOControlli	xmofn_DO
		, EseguiControlli		= cast(case when DO.xMOControlli is null then 0 else 1 end as bit)
		, xMODatiPiede			= DO.xMODatiPiede		
		, xMOQuantitaDef		= DO.xMOQuantitaDef
		, xMOTarga				= DO.xMOTarga
		, xMOBarcode			= DO.xMOBarcode		
		, xMOTerminali			= DO.xMOTerminali
		, xMODOSottoCommessa	= DO.xMODOSottoCommessa
		, xMOAutoConfirm		= DO.xMOAutoConfirm
		, xMOAA					= DO.xMOAA					-- Acquisizione Alias
		-- Codice programma di moovi da eseguire per il documento
		, xCd_xMOProgramma		= DO.xCd_xMOProgramma
		-- Campi personalizzati estesi per le rilevazioni 
		, xMOExtFld				= cast(case when exists(select * from ADB_System.aad.License where Name = 'LicF_Id' And [Value] IN (2222)) then 
										-- Documenti abilitati
										case when Cd_Do in ('OVC','DDT') then
											'<rows>
												<row nome="ArGiac" tipo="numeric" descrizione="Giacenza rilevata" richiesto="true"/>
											</rows>'
										else null
										end
									else null
									end as xml)
	from
		DO
			left join	MGCausale			on DO.Cd_MGCausale = MGCausale.Cd_MGCausale
			left join	MG			mg_p	on MGCausale.Cd_MG_P = mg_p.Cd_MG
			left join	MG			mg_a	on MGCausale.Cd_MG_A = mg_a.Cd_MG
	where
		-- Documento attivo per Moovi
			DO.xMOAttivo = 1
		-- Documento gestito dall'Operatore 
		And DO.Cd_DO in (select Cd_DO from xmovs_DOOperatore where Cd_Operatore = @Cd_Operatore)
		-- Documento gestito da tutti i terminali o Terminale abilitato
		And ((DO.xMOTerminali is null) OR (DO.Cd_DO in (select Cd_DO from xmovs_DOTerminale where Terminale = @Terminale)))
)
go

-- Documenti prelevabili (funzione snella di recuper dati di prelievo)
create function xmofn_DOTes_Prel_Smart (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_DO			char(3)			-- Documento da generare (se non passato mostra tutti i doc)
	, @Cd_CF			char(7)			-- Cliente/Fornitore per la selezione dei documenti prelevabili (se non passato mostra tutti i doc)
) returns table
/*ENCRYPTED*/
as return (
	Select 
		--  Dati di testa
		Id_DOTes				= DOTes.Id_DOTes
		, Cd_DO					= DOTes.Cd_DO
		, xCd_xMOProgramma		= DO.xCd_xMOProgramma
		, DO_Descrizione		= DO.Descrizione
		, Cd_CF					= DOTes.Cd_CF
		, Cd_CFDest				= DOTes.Cd_CFDest
		, NumeroDoc				= DOTes.NumeroDoc
		, DataDoc				= DOTes.DataDoc
		, Cd_MGEsercizio		= DOTes.Cd_MGEsercizio
		, DataConsegna			= DOTes.DataConsegna
		, Cd_DOSottoCommessa	= DOTes.Cd_DOSottoCommessa
		, NumeroDocRif			= DOTes.NumeroDocRif
		, DataDocRif			= DOTes.DataDocRif
		, Cd_PG					= DOTes.Cd_PG
	From
		DOTes
			inner join DO on DOTes.Cd_DO = DO.Cd_DO
	Where 
		-- Tipo documento incluso in tutti Doc Prelevabili di documenti Attivi per MOOVI
		DOTes.Cd_DO in (select Distinct
							DODOPrel.Cd_DO_Prelevabile 
						from 
							DODOPrel inner join dbo.xmofn_DO(@Terminale, @Cd_Operatore)	DO	on DODOPrel.Cd_DO = DO.Cd_DO
						where 
							((isnull(@Cd_DO, '') = '') Or (DODOPrel.Cd_DO = @Cd_Do))
						) 
		-- Cliente / Fornitore
		And (isnull(@Cd_CF, '') = '' Or DOTes.Cd_CF = @Cd_CF)
		-- Esecutivo
		And DOTes.Esecutivo	= 1
		-- Prelevabile
		And DOTes.Prelevabile = 1
		-- Con righe evadibili ( = 0 se completamente evaso )
		And DOTes.RigheEvadibili > 0
		-- Prelevabile da 2 anni indietro (### da inserire come parametro)
		And DOTes.EsAnno >= year(getdate()) - 2
)
go

-- Documenti prelevabili
create function xmofn_DOTes_Prel (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Cd_DO		char(3)			-- Documento da generare (se non passato mostra tutti i doc)
	, @Cd_CF		char(7)			-- Cliente/Fornitore per la selezione dei documenti prelevabili (se non passato mostra tutti i doc)
	, @Cd_CFDest	char(3)		
	, @Id_xMORL		int
) returns table 
/*ENCRYPTED*/
as return (
	select 
		*
	from (
		Select 
			--  Dati di testa
			Id_DOTes				= DOTes.Id_DOTes
			, Cd_DO					= DOTes.Cd_DO
			, xCd_xMOProgramma		= DOTes.xCd_xMOProgramma
			, DO_Descrizione		= DOTes.DO_Descrizione
			, Cd_CF					= DOTes.Cd_CF
			, CF_Descrizione		= cf.Descrizione
			, Cd_CFDest				= DOTes.Cd_CFDest
			, CFDest_Descrizione	= so.Descrizione
			, NumeroDoc				= DOTes.NumeroDoc
			, DataDoc				= DOTes.DataDoc
			, Cd_MGEsercizio		= DOTes.Cd_MGEsercizio
			, DataConsegna			= DOTes.DataConsegna
			, Cd_DOSottoCommessa	= DOTes.Cd_DOSottoCommessa
			, DOSottoCommessa_Descrizione = sc.Descrizione
			, NumeroDocRif			= DOTes.NumeroDocRif
			, DataDocRif			= DOTes.DataDocRif
			, Cd_PG					= DOTes.Cd_PG
			-- Il documento è selezionato in MOOVI
			, Selezionato			= cast(case when isnull(p.Id_DOTes, 0) = 0 then 0 else 1 end as bit)
			-- Descrizione del documento che attualmente sta prelevando il documento di testa di Arca
			-- Se nullo il documento è prelevabile
			, PrelevatoDa			= (select top 1 rl.Cd_DO + ' MOOVI [' + ltrim(rtrim(str(rl.Id_xMORL))) + '] del ' + convert(varchar(10), rl.DataDoc, 105) + ' (' + rl.Cd_Operatore + ')'  from xMORL rl inner join xMORLPrelievo rlp on rl.Id_xMORL = rlp.Id_xMORL where rlp.Id_DOTes = DOTes.Id_DOTes And rl.Stato = 0)
			-- Dati di piede
			--, DOTes.volume
			-- Campi utili ai Filtri
			, F_Doc					= (dbo.afn_FormatNumeroDoc(DOTes.Cd_DO, DOTes.NumeroDoc, DOTes.DataDoc))
			, F_Cd_ARs				= (SELECT STUFF((SELECT distinct ', ' + Cd_AR FROM DORig Where Id_DOTes = DOTes.Id_DOTes FOR XML PATH ('')), 1, 1, '')) 
			, Cd_DOs				= (SELECT STUFF((SELECT distinct ',' + DODOPrel.Cd_DO FROM DODOPrel inner join dbo.xmofn_DO(@Terminale, @Cd_Operatore) DO on DODOPrel.Cd_DO = DO.Cd_DO  Where DODOPrel.Cd_DO_Prelevabile = DOTes.Cd_DO FOR XML PATH ('')), 1, 1, '')) 
			, N_DORig				= (SELECT COUNT(*) FROM DORig WHERE DORig.Id_DOTes = DOTes.Id_DOTes and QtaEvadibile > 0)
		From
			dbo.xmofn_DOTes_Prel_Smart(@Terminale, @Cd_Operatore, @Cd_DO, @Cd_CF)	DOTes
				--inner join	DO														do		on DOTes.Cd_DO = do.Cd_DO
				inner join	CF														cf		on DOTes.Cd_CF = cf.Cd_CF
				left join	CFDest													so		on DOTes.Cd_CF = so.Cd_CF And DOTes.Cd_CFDest = so.Cd_CFDest
				left join	DOSottoCommessa											sc		on DOTes.Cd_DOSottoCommessa = sc.Cd_DOSottoCommessa
				left join (
					select distinct Id_xMORL, Id_DOTes from xMORLPrelievo where Id_xMORL = isnull(@Id_xMORL, 0)
							)p		on p.Id_DOTes = DOTes.Id_DOTes
		where 
			(ISNULL(@Cd_CFDest, '') = '' OR DOTes.Cd_CFDest = @Cd_CFDest)
	) p
	where
		F_Cd_ARs is not null
)
go

-- Funzione per la selezione di tutti gli articoli gestibili da un prelievo di RL
create function xmofn_xMORLPrelievo_AR(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMORL			int				= null
) returns @out table(Cd_AR varchar(20))
/*ENCRYPTED*/
as begin
	if (@Id_xMORL > 0) begin

		-- Verifica che esista un prelievo e non sono ammessi i fuorilista: il resulset è dei soli articoli del prelievo
		Declare @Prelievo	bit
		Declare @Fuorilista bit

		Set @Prelievo	= (case when exists(Select * From xMORLPrelievo Where Id_xMORL = @Id_xMORL) then 1 else 0 end)
		Set @Fuorilista = (Select xMOFuorilista From DO where Cd_DO = (Select Cd_DO From xMORL Where Id_xMORL = @Id_xMORL))

		-- Esiste un prelievo e non sono ammessi i fuorilista
		if (@Prelievo = 1) And (@Fuorilista = 0) begin
			-- Articoli ammessi solo quelli del prelievo
			insert into @out select distinct Cd_AR from DORig inner join xMORLPrelievo on DORig.Id_DORig = xMORLPrelievo.Id_DORig Where xMORLPrelievo.Id_xMORL = @Id_xMORL
		end else begin
			-- Tutti gli articoli ammessi
			insert into @out select Cd_AR from AR
		end

	end else begin

		-- Tutti gli articoli ammessi
		insert into @out select Cd_AR from AR

	end

	return
end 
go

-- Funzione per la validazione degli Articoli (nessun top)
create function xmofn_ARValidate(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMORL			int				= null
	, @Cd_AR			varchar(20)
) returns @out table (
	Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, DescrizioneBreve	varchar(40)
	, Cd_ARMisura		char(2)
)
/*ENCRYPTED*/
as begin
-- ### da aggiungere verifica di terminale e operatore
	declare @Cd_CF			char(7)
	set @Cd_CF = (select Cd_CF from xMORL where Id_xMORL = @Id_xMORL)
	
	insert into @out
	select 
		Cd_AR				
		, Descrizione
		, DescrizioneBreve
		, Cd_ARMisura		= upper(Cd_ARMisura)
	from
		AR
	where
			Obsoleto	= 0
		--And DBKit		= 0
		--And DBFantasma	= 0
			-- Per ID_xMORL <> nullo verifica che gli articoli possano essere selezionati solo dal prelievo
		And Cd_AR In (Select Cd_AR From xmofn_xMORLPrelievo_AR(@Terminale, @Cd_Operatore, @Id_xMORL))
			-- Gestione del filtro
		And (ISNULL(@Cd_AR, '') = '' OR (Cd_AR = @Cd_AR))
	return
end
go	

-- Funzione per la ricerca degli Articoli attivi per Moovi (top 100)
create function xmofn_AR(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMORL			int				= null
	, @Filtro			varchar(100)	= null
	, @Fittizio			bit				= 0 
) returns @out table (
	Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, DescrizioneBreve	varchar(40)
	, Cd_ARMisura		char(2)
)
/*ENCRYPTED*/
as begin
	
	declare @Cd_CF			char(7)
	set @Cd_CF = (select Cd_CF from xMORL where Id_xMORL = @Id_xMORL)
	
	insert into @out
	select top 100 
		Cd_AR				
		, Descrizione
		, DescrizioneBreve
		, Cd_ARMisura		= upper(Cd_ARMisura)
	from
		AR
	where
			Obsoleto	= 0
		And DBKit		= 0
		And DBFantasma	= 0
			-- Per ID_xMORL <> nullo verifica che gli articoli possano essere selezionati solo dal prelievo
		And Cd_AR In (Select Cd_AR From xmofn_xMORLPrelievo_AR(@Terminale, @Cd_Operatore, @Id_xMORL))
			-- Gestione del filtro
		And
			(
				(isnull(@Filtro, '') = '')  
				Or 
				(
					    Cd_AR like ('%' + @Filtro + '%') 
					Or  Descrizione like('%' + @Filtro + '%') 
					-- Codice alternativo C/F 
					Or  Cd_AR in (
									Select Cd_AR From ARCodCF Where CodiceAlternativo = @Filtro And (@Cd_CF is null Or Cd_CF = @Cd_CF)
								)
					-- Alias
					Or	Cd_AR in (
									Select Cd_AR From ARAlias Where Alias = @Filtro
								)
				)
			)
		-- O tutti gli articoli o solo quelli NON fittizi
		And ((@Fittizio = 1) Or (Fittizio = @Fittizio))
	return
end
go	

-- Funzione dei lotti 
create function xmofn_ARLotto (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_AR			varchar(20)
	, @Cd_MG			char(5)
	, @Cd_MGUbicazione	varchar(20)
	, @Id_xMORL			int				= null
	, @Filtro			varchar(100)	= null
	, @GiacPositiva		bit				= 1
) returns @out table (
	Cd_AR				varchar(20)
	, Cd_ARLotto		varchar(20)
	, Descrizione		varchar(80)
	, DataScadenza		smalldatetime
	, Cd_CF				char(7)
	, Quantita			numeric(18,8)
	, Cd_ARMisura		char(2)
	, Cd_MG				char(5)
	, Cd_MGUbicazione	varchar(20)
)
/*ENCRYPTED*/
as begin
	
	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	insert into @out
	select 
		arl.Cd_AR
		, arl.Cd_ARLotto
		, arl.Descrizione
		, arl.DataScadenza
		, arl.Cd_CF
		, mgg.Quantita
		, arm.Cd_ARMisura
		, mgg.Cd_MG
		, mgg.Cd_MGUbicazione
	from 
		ARLotto							arl
			inner join ARARMisura		arm on arl.Cd_AR = arm.Cd_AR And arm.DefaultMisura = 1
			left join (
				-- I filtri sul magazzino vanno eseguiti nella subquery altrimenti non funziona la left join
				select
					Cd_AR
					, Cd_ARLotto
					, Quantita
					, Cd_MG
					, Cd_MGUbicazione
				from 
					dbo.MGGiacEx(@Cd_MGEsercizio) 
				where
				-- Filtri su magazzino 
						((isnull(@Cd_MG, '') = ''			Or Cd_MG = @Cd_MG)) 
					And (isnull(@Cd_MGUbicazione, '') = '' Or Cd_MGUbicazione = @Cd_MGUbicazione)
				) mgg
						on arl.Cd_AR = mgg.Cd_AR And arl.Cd_ARLotto = mgg.Cd_ARLotto 
	where 
			(isnull(@Cd_AR, '') = ''			Or arl.Cd_AR = @Cd_AR) 
		-- Se è stato passato un ID_xMORL verifica che gli articoli possano essere selezionati solo dal prelievo
		And arl.Cd_AR In (Select Cd_AR From xmofn_xMORLPrelievo_AR(@Terminale, @Cd_Operatore, @Id_xMORL))
		-- Mostra tutti i lotti se non è richiesto il vincolo di giacenza positiva
		And (@GiacPositiva = 0 Or (@GiacPositiva = 1 And mgg.Quantita > 0))
			-- Gestione del filtro
           And 
			(
					isnull(@Filtro, '') = '' 
				Or
				(
						arl.Cd_ARLotto Like ('%' + @Filtro + '%')
					Or  arl.Descrizione Like ('%' + @Filtro + '%')
				)
			)

	return 
end
go

-- Funzione delle um dell'articolo 
create function xmofn_ARARMisura (
	@Terminale			varchar(39)		-- Terminale che effettua la richiesta
	, @Cd_Operatore		varchar(20)		-- Operatore che effettua la richiesta
	, @Cd_AR			varchar(20) 
	, @TipoARMisura		char(1)			-- nullo se non esiste un DO gestito
	, @xMOUmDef			smallint		-- nullo se non esiste un DO gestito
) returns @out table(
	Ordine			int identity(1,1)
	, Cd_ARMisura	char(2)
	, UMFatt		numeric(18,8)	
	, DefaultMisura bit
)
/*ENCRYPTED*/
as begin
--	ORDINATE PER:
--		1) se passato il documento prevale xMOUmDef definita (es. xMOUmDef di DDT è la 2 -> la funzione ordina per prima la seconda unità di misura)
--		2) se passato ciclo prevale acquito o vendita (es. xMOUmDef di DDT è la 2 -> la funzione ordina per prima la seconda unità di misura)
--		3) DefaultMisura
	
	-- Per la gestione degli alias e dei codici C/F l'articolo va sempre convertito
	set @Cd_AR = (select dbo.xmofn_Get_AR_From_AAA(@Cd_AR, 'null'))

	insert into @out (Cd_ARMisura, UMFatt, DefaultMisura)
	select 
		Cd_ARMisura			= upper(Cd_ARMisura)
		, UMFatt
		, DefaultMisura
	from
		( 
			select
				n = ROW_NUMBER() over(order by DefaultMisura desc, Riga) 
				, Cd_ARMisura
				, UMFatt
				, DefaultMisura
				, TipoARMisura
			from 
				ARARMisura
			where
				Cd_AR = @Cd_AR
		) ARARMisura
	Order by 
		case when n = isnull(@xMOUmDef, 0) then 1 else 0 end							desc
		, case when CHARINDEX(TipoARMisura, @TipoARMisura + 'E') > 0 then 1 else 0 end	desc
		, DefaultMisura																	desc
	
	return 
end
go

-- Funzione delle um dell'articolo 
create function xmofn_ARARMisura2 (
	@Terminale			varchar(39)		-- Terminale che effettua la richiesta
	, @Cd_Operatore		varchar(20)		-- Operatore che effettua la richiesta
	, @Cd_AR			varchar(20) 
	, @Cd_ARMisuraDef	char(2)
) returns @out table(
	Ordine			int identity(1,1)
	, Cd_ARMisura	char(2)
	, UMFatt		numeric(18,8)	
	, DefaultMisura bit
)
/*ENCRYPTED*/
as begin
	
	if isnull(@Cd_ARMisuraDef, '') = ''		set @Cd_ARMisuraDef = ''
	
	-- Per la gestione degli alias e dei codici C/F l'articolo va sempre convertito
	set @Cd_AR = (select dbo.xmofn_Get_AR_From_AAA(@Cd_AR, 'null'))
	insert into @out (Cd_ARMisura, UMFatt, DefaultMisura)
	select 
		Cd_ARMisura			= upper(Cd_ARMisura)
		, UMFatt
		, DefaultMisura
	from
		( 
			select
				n = ROW_NUMBER() over(order by DefaultMisura desc, Riga) 
				, Cd_ARMisura
				, UMFatt
				, DefaultMisura
				, TipoARMisura
			from 
				ARARMisura
			where
				Cd_AR = @Cd_AR
		) ARARMisura
	Order by 
		case when Cd_ARMisura = @Cd_ARMisuraDef then 0 else 1 end	asc						
		, DefaultMisura												desc
	
	return 
end
go

--funzione di tutti i clienti e fornitori attivi per operatore e/o terminale (ESCLUDE IL TOP!)
create function xmofn_CF_ALL (
	@Terminale		varchar(39)		-- Terminale che effettua la richiesta
	, @Cd_Operatore	varchar(20)		-- Operatore che effettua la richiesta
	, @TipoCF		char(1)			-- 
	, @Cd_DO		char(3)			-- Mostra solo i documenti utili alla generazione del documento
	, @TipoPrelievo	smallint		-- Prelievo: 0 = nessun prelievo; 1 = Prelievo; 2 = Prelievo obbligatorio
) returns table
/*ENCRYPTED*/
as return
( 
	select 
		* 
	from (
			select 
				Cd_CF					= CF.Cd_CF
				, Descrizione			= CF.Descrizione
				, TipoCF				= CF.TipoCF
				--	 , Note_CF			### Implementare la visualizzazione delle note sulle liste
				, Destinazioni			= case when isnull(CFDest.Cd_CF, '') = '' then 0 else 1 end  
				, CFDest_Default		= case when CFDest.DefaultDestinazione = 1 then CFDest.Cd_CFDest	else null end
				, CFDest_Descrizione	= case when CFDest.DefaultDestinazione = 1 then CFDest.Descrizione	else null end
				, HaPrelievi			= case when isnull(DOTes.Cd_CF, '') = '' then 0 else 1 end  
			from 
				CF
					left join 
					-- Primo DefaultDestinazione per cliente
						(select top 1 with ties Cd_CF, Cd_CFDest, Descrizione, DefaultDestinazione from CFDest where Obsoleto = 0 order by row_number() over(partition by Cd_CF order by DefaultDestinazione desc)) 
								as CFDest	on CF.Cd_CF = CFDest.Cd_CF
					-- Elenco clienti che possiedo doc prelevabili
					left join 
						(Select distinct Cd_CF from dbo.xmofn_DOTes_Prel_Smart(@Terminale, @Cd_Operatore, @Cd_DO, null))
								as DOTes	on CF.Cd_CF = DOTes.Cd_CF
			where
					CF.Obsoleto = 0 
				-- Seleziona tutti o colo il C/F
				And	((Isnull(@TipoCF, '') = '') Or (CF.TipoCF = @TipoCF))
		) cf
	where
		(isnull(@TipoPrelievo, 0) < 2) Or (@TipoPrelievo = 2 And cf.HaPrelievi = 1)
)
go

--funzione dei clienti e fornitori
create function xmofn_CF (
	@Terminale		varchar(39)		-- Terminale che effettua la richiesta
	, @Cd_Operatore	varchar(20)		-- Operatore che effettua la richiesta
	, @TipoCF		char(1)			-- 
	, @Cd_DO		char(3)			-- Mostra solo i documenti utili alla generazione del documento
	, @TipoPrelievo	smallint		-- Prelievo: 0 = nessun prelievo; 1 = Prelievo; 2 = Prelievo obbligatorio
	, @Filtro		varchar(100)
) returns table
/*ENCRYPTED*/
as return
( 
	select top 100
		*
	from 
		dbo.xmofn_CF_ALL(@Terminale, @Cd_Operatore, @TipoCF, @Cd_DO, @TipoPrelievo) cf
	where
			isnull(@Filtro, '') = '' 
		Or
		(
				CF.Cd_CF		Like ('%' + @Filtro + '%')
			Or  CF.Descrizione	Like ('%' + @Filtro + '%')
		)
)
go

--funzione delle destinazioni dei clienti e fornitori
create function xmofn_CFDest (
	@Terminale		varchar(39)		-- Terminale che effettua la richiesta
	, @Cd_Operatore	varchar(20)		-- Operatore che effettua la richiesta
	, @TipoCF		char(1)			-- 
	, @Cd_CF		char(7)			-- Mostra solo le destinazioni del C/F
	, @Cd_DO		char(3)			-- Mostra solo i documenti utili alla generazione del documento
	, @TipoPrelievo	smallint		-- Prelievo: 0 = nessun prelievo; 1 = Prelievo; 2 = Prelievo obbligatorio
	, @Filtro		varchar(100)
) returns table
/*ENCRYPTED*/
as return
( 
	select 
		Cd_CFDest				= CFDest.Cd_CFDest
		, Descrizione			= CFDest.Descrizione
		, Cd_CF					= CFDest.Cd_CF
		, CF_Descrizione		= cf.Descrizione
		-- , CFDest.Note_CFDest	### Implementare la visualizzazione delle note sulle liste
		, DefaultDestinazione	= CFDest.DefaultDestinazione
	from 
		CFDest
			inner join dbo.xmofn_CF_ALL(@Terminale, @Cd_Operatore, @TipoCF, @Cd_DO, @TipoPrelievo) cf on CFDest.Cd_CF = cf.Cd_CF
	where
			CFDest.Obsoleto = 0 
		And (isnull(@Cd_CF, '') = ''  Or (cf.Cd_CF = @Cd_CF))
		-- Gestione del filtro
           And 
			(
					isnull(@Filtro, '') = '' 
				Or
				(
						CFDest.Cd_CFDest	Like ('%' + @Filtro + '%')
					Or  CFDest.Descrizione	Like ('%' + @Filtro + '%')
					Or  cf.Cd_CF			Like ('%' + @Filtro + '%') 
					Or  cf.Descrizione		Like ('%' + @Filtro + '%')
				)
			)
)
go

-- funzione dei magazzini
create function xmofn_MG (
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Filtro		varchar(100)	= null
) returns table
/*ENCRYPTED*/
as return
(
	select 
		Cd_MG 
		, Fiscale
		, Descrizione 
		, MG_UbicazioneObbligatoria 
	from 
		MG
	where
           isnull(@Filtro, '') = '' Or
           (
               Cd_MG like ('%' + @Filtro + '%') Or
               Descrizione like('%' + @Filtro + '%') 
           ) 
)
go

-- Elenco delle ubicazioni dove risulta giacenza per l'articolo
create function xmofn_ARMGUbicazione_Giac(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_AR			varchar(20)
	, @Cd_MG			char(5)					
) returns @out table (
	Cd_MG					char(5)
	, Cd_MGUbicazione		varchar(20)
	, Descrizione			varchar(80)
	, Cd_ARLotto			varchar(20)
	, Cd_DOSottoCommessa	varchar(20)
	, Quantita				numeric(18,8)
	, QuantitaDisp			numeric(18,8)
	, QuantitaDImm			numeric(18,8)
	, DefaultMGUbicazione	varchar(20)
)
/*ENCRYPTED*/
as begin

	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	insert into @out
	Select 
		Cd_MG					= MGUbicazione.Cd_MG
		, Cd_MGUbicazione		= MGUbicazione.Cd_MGUbicazione
		, Descrizione			= MGUbicazione.Descrizione
		, Cd_ARLotto			= m.Cd_ARLotto
		, Cd_DOSottoCommessa	= m.Cd_DoSottoCommessa
		, Quantita				= isnull(m.Quantita, 0)
		, QuantitaDisp			= isnull(m.QuantitaDisp, 0)	
		, QuantitaDImm			= isnull(m.QuantitaDimm, 0)
		, DefaultMGUbicazione	= IsNull(X.DefaultMGUbicazione, 0) 
	From (
			-- Elenco delle ubicazioni unite ai magazzini
						Select Cd_MG, Cd_MGUbicazione	, Descrizione							From MGUbicazione
			Union All	Select Cd_MG, Null				, 'Ubicazione Vuota del ' + Descrizione From MG
		) MGUbicazione
			Left Join ARMGUbicazione X On	X.Cd_AR							= @Cd_AR						And 
											X.Cd_MG 						= MGUbicazione.Cd_MG 			And 
											isnull(X.Cd_MGUbicazione, '')	= isnull(MGUbicazione.Cd_MGUbicazione, '') 	And 
											X.DefaultMGUbicazione			= 1
		Left Join (
			Select
				Cd_MG
				, Cd_MGUbicazione
				, Cd_ARLotto
				, Cd_DoSottoCommessa
				, Quantita		= Sum(Quantita)		
				, QuantitaDimm	= Sum(QuantitaDimm) 
				, QuantitaDisp	= Sum(QuantitaDisp) 
			From
				MGDispEx(@Cd_MGEsercizio)
			Where
					Cd_AR =  @Cd_AR And Cd_MG Is Not Null /* escludo contributo produzione */
				And ((isnull(@Cd_MG, '') = '') Or (Cd_MG = @Cd_MG))
			Group By
				Cd_MG
				, Cd_MGUbicazione
				, Cd_ARLotto
				, Cd_DoSottoCommessa
		) m On m.Cd_MG = MGUbicazione.Cd_MG And IsNull(m.Cd_MGUbicazione, '') = IsNull(MGUbicazione.Cd_MGUbicazione, '')
	Where 
		((isnull(@Cd_MG, '') = '') Or (MGUbicazione.Cd_MG = @Cd_MG))
	-- Order By 1, 2
	
	return 
end
go
	
-- Elenco degli articoli in giacenza nelle ubicazioni
create function xmofn_MGUbicazioneAR_Giac(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_MGUbicazione	varchar(20) 
	, @Cd_MG			char(5)		
) returns @out table (
	Cd_MG				char(5)
	, Cd_MGUbicazione	varchar(20)
	, Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, Cd_ARMisura		char(2)
	, Quantita			numeric(18,8)
	, QuantitaDisp		numeric(18,8)
	, QuantitaDimm		numeric(18,8)
	, StatoGiac			smallint
)
/*ENCRYPTED*/
as begin

	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	insert into @out
	Select
		mg.Cd_MG
		, mg.Cd_MGUbicazione
		, mg.Cd_AR
		, AR.Descrizione
		, arar.Cd_ARMisura
		, Quantita		= Sum(Quantita)		
		, QuantitaDisp	= Sum(QuantitaDisp) 
		, QuantitaDimm	= Sum(QuantitaDimm) 	
		, StatoGiac		= dbo.xmofn_StatoGiac(@Terminale, @Cd_Operatore, mg.Cd_MG, mg.Cd_MGUbicazione, null)
	From
		MGDispEx(@Cd_MGEsercizio) mg
			inner join ARARMisura	arar	on arar.Cd_AR =  mg.Cd_AR and DefaultMisura = 1
			inner join AR			ar		on ar.Cd_AR	= mg.Cd_AR
	where 
		((isnull(@Cd_MGUbicazione, '') = '') Or (Cd_MGUbicazione = @Cd_MGUbicazione)) 
		And ((isnull(@Cd_MG, '') = '') Or (Cd_MG = @Cd_MG))
	Group By
		mg.Cd_MG
		, mg.Cd_MGUbicazione
		, mg.Cd_AR
		, ar.Descrizione
		, arar.Cd_ARMisura

	return
end
go

create function xmofn_MGUbicazione (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Cd_MG		char(5)			= null -- Se passato alla funzione mostra tutte le ubicazioni dei magazzini
	, @Cd_AR		varchar(20)		= null -- Se passato alla funzione mostra tutte le ubicazioni dell'articolo
	, @Filtro		varchar(100)	= null
) returns @out table (
	Cd_MGUbicazione			varchar(20)
	, Descrizione			varchar(50)
	, Cd_MG					char(5)
	, DefaultMGUbicazione	bit
	, StatoGiac				smallint
) 
/*ENCRYPTED*/
as begin
	
	--Normalizza i campi
	set @Cd_MG = case when isnull(@Cd_MG, '') = '' then null else @Cd_MG end
	set @Cd_AR = case when isnull(@Cd_AR, '') = '' then null else @Cd_AR end

	declare @Id_Operatore int

	set @Id_Operatore = (select Id_Operatore from Operatore where Cd_Operatore = @Cd_Operatore)
	
	insert into @out
	select 
		mgu.Cd_MGUbicazione
		, mgu.Descrizione
		, mgu.Cd_MG
		, ors.DefaultMGUbicazione
		, StatoGiac		= dbo.xmofn_StatoGiac(@Terminale, @Cd_Operatore, @Cd_MG, mgu.Cd_MGUbicazione, null) 
	from 
		-- Ubicazioni dell'articolo (tutte o quelle definite in anafrafica
		orsMGUbicazione(@Id_Operatore, @Cd_AR, @Cd_MG)		ors
			inner join MGUbicazione							mgu		on ors.Cd_MG = mgu.Cd_MG And ors.Cd_MGUbicazione = mgu.Cd_MGUbicazione
	where
           isnull(@Filtro, '') = '' Or
           (
               mgu.Cd_MGUbicazione like ('%' + @Filtro + '%') Or
               mgu.Descrizione like('%' + @Filtro + '%') 
           )
	return
end
go

create function xmofn_DOCaricatore( 
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Filtro		varchar(100)	= null
) returns table
/*ENCRYPTED*/
as return 
(		
	select 
		Cd_DOCaricatore = Cd_DOSdTAnag
		, Descrizione	
	from 
		DoSdTAnag 
	where 
		Left(Cd_DoSdTAnag, 1) = '1'
		And  (isnull(@Filtro, '') = '' Or
		   (
				Cd_DOSdTAnag like ('%' + @Filtro + '%') Or
				Descrizione like('%' + @Filtro + '%') 
			) 
		)
)
go

create function xmofn_xMOTR_To_Edit(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMOTR			int
)returns table
/*ENCRYPTED*/
as return (
	
	select top 1
		Id_xMOTR
		, Descrizione
		, DataMov
		, Cd_MG_P
		, Cd_MGUbicazione_P
		, Cd_MG_A
		, Cd_MGUbicazione_A
		, Cd_DOSottoCommessa
	from 
		xMOTR
	Where
		Stato = 0	-- In compilazione
		And Terminale = @Terminale
		And Cd_Operatore = @Cd_Operatore
	    And xMOTR.Id_xMOTR = Case When @Id_xMOTR > 0 Then @Id_xMOTR Else xMOTR.Id_xMOTR End
)
go

-- Restituisce l'elenco delle righe lette dal mg di partenza
create function xmofn_xMOTRRig_P_AR (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMOTR			int
) returns table
/*ENCRYPTED*/
as return
(
	select
		Ordine				= ROW_NUMBER() over(order by Ts desc, Id_xMOTRRig_P)
		, Id_xMOTRRig_P
		, Id_xMOTR
		, Cd_AR
		, Cd_ARLotto
		, Cd_ARMisura		= upper(Cd_ARMisura)
		, FattoreToUM1
		, Quantita
		, Cd_MG_P
		, Cd_MGUbicazione_P
		, DataOra
	from 
		xMOTRRig_P
	where
		Id_xMOTR = @Id_xMOTR
)
go

-- funzione del xMOTRRig_A
create function xmofn_xMOTRRig_A (
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
) returns table
/*ENCRYPTED*/
as return
(
	select     
		Id_xMOTR
		, Id_xMOTRRig_A
	    , Cd_ARMisura
	    , FattoreToUM1
	    , Quantita
	    , Cd_MG_A
	    , Cd_MGUbicazione_A
	    , Id_MGMovInt
		, Id_xMOTRRig_P
		, DataOra
	from 
		xMOTRRig_A
)
go

-- Restituisce l'elenco delle righe lette dal mg di partenza
create function xmofn_xMOTRRig_A_AR (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_xMOTR			int
) returns table
/*ENCRYPTED*/
as return
(
	select 
		Ordine = ROW_NUMBER() over(order by case when A.Quantita_R > 0 then 0 else 1 end, A.Cd_AR) -- Ordinate in modo da avere al top della lista le righe incomplete 
		, A.*
	from (
		select
			xMOTRRig_P.Id_xMOTRRig_P
			, xMOTRRig_P.Id_xMOTR
			, xMOTRRig_P.Cd_AR
			, xMOTRRig_P.Cd_ARLotto
			, Cd_ARMisura				= upper(xMOTRRig_P.Cd_ARMisura)
			, xMOTRRig_P.FattoreToUM1
			, Quantita_P				= xMOTRRig_P.Quantita																			-- Quantita totale
			, Quantita_A				= isnull(xMOTRRig_A.QuantitaToUM1, 0) / xMOTRRig_P.FattoreToUM1									-- Quantita letta convertita
			, Quantita_R				= xMOTRRig_P.Quantita - (isnull(xMOTRRig_A.QuantitaToUM1, 0) / xMOTRRig_P.FattoreToUM1)			-- Quantita residua
		from 
			xMOTRRig_P
				left join (	select
								Id_xMOTR
								, Id_xMOTRRig_P
								, Ts				= Max(Ts)
								, QuantitaToUM1		= Sum(Quantita * FattoreToUM1)
							from 
								xMOTRRig_A
							where
								Id_xMOTR = @Id_xMOTR
							group by 
								Id_xMOTR
								, Id_xMOTRRig_P
							) as xMOTRRig_A 
					on xMOTRRig_P.Id_xMOTR = xMOTRRig_A.Id_xMOTR and xMOTRRig_P.Id_xMOTRRig_P = xMOTRRig_A.Id_xMOTRRig_P
		where
			xMOTRRig_P.Id_xMOTR = @Id_xMOTR
	) A
)
go

create function xmofn_xMOTRRig_Totali (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_xMOTR		int				-- Elenco degli id_dotes selezionati per il prelievo
) returns @out table (
	Id_xMOTR			int
	, Ar_Totali			int		--
	, Ar_Incompleti		int		-- Articoli che nell'arrivo hanno una quantità minore rispetto a quella di partenza
) 
/*ENCRYPTED*/
as begin

	insert into @out 
	select 									
		Id_xMOTR			= @Id_xMOTR
		, Ar_Totali			= (select count(*) from (select distinct Cd_AR from xMOTRRig_P where Id_xMOTR = @Id_xMOTR) as r)
		, Ar_Incompleti		= (select count(*) from (select distinct Cd_AR from dbo.xmofn_xMOTRRig_A_AR(@Terminale, @Cd_Operatore, @Id_xMOTR) where Quantita_R > 0) as i)

	return
end
go

create function xmofn_xMOListener(
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
) returns table
/*ENCRYPTED*/
as return
	(
	select 
		Id_xMOListener
		, Cd_xMOListener
		, IP
		, Descrizione
		, ListenPort
		, ReplayPort
		, Devices		= (select COUNT(*) from xMOListenerDevice where xMOListenerDevice.Cd_xMOListener = xMOListener.Cd_xMOListener)
	from 
		xMOListener
	where 
		Attivo = 1
) 
go

-- Elenco dei moduli di un listner
create function xmofn_xMOListener_Moduli (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @ComputerName varchar(64)	
	, @Cd_DO		char(3)		= null
) returns table
/*ENCRYPTED*/
as return (
	-- Global
	Select 
		Cd_DO				= DOReport.Cd_DO
		, Tipo				= 1 -- Global
		, ComputerName		= DOReport.ComputerName
		, Id_DOReport		= DOReport.Id_DOReport
		, UserReport		= DOReport.UserReport
		, RptDocName		= ReportDocAll.RptDocName
		, Descrizione		= ReportDocAll.Descrizione
		, Device			= DOReport.Device
		, NumeroCopie		= DOReport.NumeroCopie
		, OfficialReport	= DOReport.OfficialReport
	From 
		DOReport
			inner join ReportDocAll on DOReport.UD_ReportDoc = ReportDocAll.Ud_ReportDoc
	where 
			ComputerName IS NULL 
		And (isnull(@Cd_DO, '') = '' OR DOReport.Cd_DO = @Cd_DO)
	union
	-- Local
	Select 
		Cd_DO				= DOReport.Cd_DO
		, Tipo				= 2 -- Local
		, ComputerName		= DOReport.ComputerName
		, Id_DOReport		= DOReport.Id_DOReport
		, UserReport		= DOReport.UserReport
		, RptDocName		= ReportDocAll.RptDocName
		, Descrizione		= ReportDocAll.Descrizione
		, Device			= DOReport.Device
		, NumeroCopie		= DOReport.NumeroCopie
		, OfficialReport	= DOReport.OfficialReport
	From 
		DOReport
			inner join ReportDocAll on DOReport.UD_ReportDoc = ReportDocAll.Ud_ReportDoc
	where 
			ComputerName Is Not NULL 
			-- A volte arca memorizza nel campo ComputerName ilcodice operatore che ha effettuato il login di arca
		And (ComputerName = @ComputerName Or ComputerName = @Cd_Operatore)
		And (isnull(@Cd_DO, '') = '' OR DOReport.Cd_DO = @Cd_DO)
)
go

-- Elenco dei Device per Listener con numero copie
create function xmofn_xMOListenerDevice (
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Cd_xMOListener varchar(64)
) returns table
/*ENCRYPTED*/
as return (
	select
		Id_xMOListenerDevice
		, l.Device
		, d.NumeroCopie
	from
		xMOListenerDevice l
		left join DOReport d on d.Device = l.Device
	where
		Cd_xMOListener  = @Cd_xMOListener --(select distinct Cd_xMOListener from xMOListener where IP = @IP and attivo = 1)
)
go

-- Elenco delle linee collegate all'operatore attraverso il magazzino
create function xmofn_xMOLinea (
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
) returns table
/*ENCRYPTED*/
as return (

	select
		Cd_xMOLinea		= Cd_xMOLinea
		, Descrizione	= Descrizione + case when ISNULL(Cd_MG, '') = '' then '' else ' [Mg:' + Cd_MG + ']' end
		, Cd_MG			= Cd_MG
	from
		xMOLinea
	where
			MatAttivo = 1
		And (
		-- Gestione rovesciata dalla 0.007:
			-- Seleziona tutte le linee con lo stesso magazzino dell'operatore (Se presente) o tutte
				(Cd_MG = (select xMOCd_MG from Operatore where Cd_Operatore = @Cd_Operatore))
			Or 
				((select xMOCd_MG from Operatore where Cd_Operatore = @Cd_Operatore) is null)
			)
		-- Deprecato
		-- Seleziona tutte le linee senza magazzino e le linee con lo stesso magazzino dell'operatore
		--(Cd_MG is null) Or (Cd_MG = (select xMOCd_MG from Operatore where Cd_Operatore = @Cd_Operatore))
		)
go

-- Elenco delle sottocommesse
create function xmofn_xMODOSottoCommessa_Std (
	@Cd_CF			char(7)
	, @Filtro		varchar(100)	= null
) returns table
/*ENCRYPTED*/
as return (
	select top 100
		Cd_DOSottoCommessa
		, Descrizione 
		, Cd_DOCommessa
	from 
		DOSottoCommessa 
	where 
		DataFineReale is null
		And 
		(
			isnull(@Cd_CF, '') = ''
			Or Cd_CF = @Cd_CF
		)
		And
		(
			isnull(@Filtro, '') = '' Or
		    (
				Cd_DOSottoCommessa like ('%' + @Filtro + '%') Or
				Cd_DOCommessa like ('%' + @Filtro + '%') Or
		        Descrizione like('%' + @Filtro + '%') 
		    ) 
		)
)

go
-----------------------------------------------------------------------------------
create function xmofn_xMODOSottoCommessa (
	@Cd_CF			char(7)
	, @Filtro		varchar(100)	= null
) returns @out table (
		Cd_DOSottoCommessa	varchar(20)
		, Descrizione		varchar(80)
		, Cd_DOCommessa		varchar(20)
) as begin
	if OBJECT_ID('xmofn_xMODOSottoCommessa_Usr') is null
		insert into @out select * from dbo.xmofn_xMODOSottoCommessa_Std(@Cd_CF, @Filtro)
	else
		insert into @out select * from dbo.xmofn_xMODOSottoCommessa_Usr(@Cd_CF, @Filtro)
	return 
end
go


-- drop function xmofn_xMOUniLog
create function xmofn_xMOUniLog(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
) returns table
/*ENCRYPTED*/
as return (
	select 
		Ordine = ROW_NUMBER() over(order by cast(ULDefault as int) desc, Cd_xMOUniLog)
		, Cd_xMOUniLog
		, Descrizione
		, PesoTaraMks
		, LarghezzaMks
		, LunghezzaMks
		, AltezzaMks
		, VolumeMks
	from 
		xMOUniLog 
	where 
			(
				(isnull(@Terminale, '') = '') 
				Or
				((select top 1 LogInTerminale from xMOImpostazioni) = 0)
				Or 
				(@Terminale in (select Terminale from xmovs_UniLogTerminale)))
		And ((isnull(@Cd_Operatore, '') = '') Or (@Cd_Operatore in (select Cd_Operatore from xmovs_UniLogOperatore)))
)
go

create function xmofn_xMORLPackListRef (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
	, @PackListRef	varchar(20)
) returns table
/*ENCRYPTED*/
as return (
	select 
		Ordine					= ROW_NUMBER() over(Order by xMORLPackListRef.PackListRef)
		, Id_xMORLPackListRef	= xMORLPackListRef.Id_xMORLPackListRef
		, PackListRef			= xMORLPackListRef.PackListRef
		, Cd_xMOUniLog			= xMORLPackListRef.Cd_xMOUniLog	
		, PesoTaraMks			= xMORLPackListRef.PesoTaraMks	
		, PesoNettoMks			= xMORLPackListRef.PesoNettoMks	
		, PesoLordoMks			= xMORLPackListRef.PesoLordoMks	
		, AltezzaMks			= xMORLPackListRef.AltezzaMks	
		, LunghezzaMks			= xMORLPackListRef.LunghezzaMks	
		, LarghezzaMks			= xMORLPackListRef.LarghezzaMks	
		, VolumeMks				= xMORLPackListRef.VolumeMks
	from 
		xMORLPackListRef 
			left join xMOUniLog on xMORLPackListRef.Cd_xMOUniLog = xMOUniLog.Cd_xMOUniLog
	where 
		xMORLPackListRef.Id_xMORL = @Id_xMORL 
		And ((isnull(@PackListRef , '') = '') Or PackListRef = @PackListRef)
)
go

-- elenco articoli all'interno di ciascun pacco dove le righe sono suddivise per singola lettura effettuata
create function xmofn_xMORLRigPackingList_AR (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
) returns table
/*ENCRYPTED*/
as return (
	select 
		Ordine					= ROW_NUMBER() over(partition by xMORLRigPackList.PackListRef Order by xMORLRigPackList.PackListRef)
		, PackListRef			= xMORLRigPackList.PackListRef
		, Id_xMORLRigPackList	= xMORLRigPackList.Id_xMORLRigPackList
		, Id_xMORLRig			= xMORLRigPackList.Id_xMORLRig
		, Cd_AR					= xMORLRig.Cd_AR
		, Cd_ARLotto			= xMORLRig.Cd_ARLotto
		, Cd_ARMisura			= UPPER(xMORLRig.Cd_ARMisura)
		, Qta					= xMORLRigPackList.Qta
		, PesoNettoKg			= (Ar.PesoNetto * Ar.PesoFattore) * xMORLRigPackList.Qta
		, PesoLordoKg			= (Ar.PesoLordo * Ar.PesoFattore) * xMORLRigPackList.Qta
		, VolumeM3				= Ar.VolumeMks * xMORLRigPackList.Qta
	from 
		xMORLRigPackList 
			inner join xMORLRig on xMORLRigPackList.Id_xMORLRig = xMORLRig.Id_xMORLRig
			inner join AR on xMORLRig.Cd_AR = AR.Cd_AR
	where 
		xMORLRig.Id_xMORL = @Id_xMORL
)
go

-- elenco articoli all'interno di ciascun pacco dove le righe sono raggruppate a parità di ar 
create function xmofn_xMORLRigPackingList_AR_GRP (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
) returns table
/*ENCRYPTED*/
as return (
		select
			Ordine					= row_number() over(partition by pkl.PackListRef order by min(pkl.Ordine))
			, PackListRef			= pkl.PackListRef
			, Id_xMORLRigPackList	= null
			, Id_xMORLRig			= null
			, Cd_AR					= pkl.Cd_AR
			, Cd_ARLotto			= pkl.Cd_ARLotto
			, Cd_ARMisura			= pkl.Cd_ARMisura
			, Qta					= sum(pkl.Qta)
			, PesoNettoKg			= sum(pkl.PesoNettoKg)
			, PesoLordoKg			= sum(pkl.PesoLordoKg)
			, VolumeM3				= sum(VolumeM3)
		from
			(
				select  
					Ordine					= ROW_NUMBER() over(partition by xMORLRigPackList.PackListRef Order by xMORLRigPackList.PackListRef)
					, PackListRef			= xMORLRigPackList.PackListRef
					, Id_xMORLRigPackList	= xMORLRigPackList.Id_xMORLRigPackList
					, Id_xMORLRig			= xMORLRigPackList.Id_xMORLRig
					, Cd_AR					= xMORLRig.Cd_AR
					, Cd_ARLotto			= xMORLRig.Cd_ARLotto
					, Cd_ARMisura			= UPPER(xMORLRig.Cd_ARMisura)
					, Qta					= xMORLRigPackList.Qta
					, PesoNettoKg			= (Ar.PesoNetto * Ar.PesoFattore) * xMORLRigPackList.Qta
					, PesoLordoKg			= (Ar.PesoLordo * Ar.PesoFattore) * xMORLRigPackList.Qta
					, VolumeM3				= Ar.VolumeMks * xMORLRigPackList.Qta
				from 
					xMORLRigPackList 
						inner join xMORLRig on xMORLRigPackList.Id_xMORLRig = xMORLRig.Id_xMORLRig
						inner join AR on xMORLRig.Cd_AR = AR.Cd_AR
				where 
					xMORLRig.Id_xMORL = @Id_xMORL
			) as pkl
		group by
			Cd_AR					
			, PackListRef			
			, Cd_ARLotto			
			, Cd_ARMisura			
)
go

create function xmofn_xMORLRigPackingList (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
) returns table
/*ENCRYPTED*/
as return (
	-- 
	select 
		Ordine = ROW_NUMBER() over(order by rlrpl.PackListRef desc)
		, rlrpl.PackListRef
		, rlpkr.Cd_xMOUniLog
		, rlpkr.PesoNettoMks
		, rlpkr.PesoLordoMks
		, rlpkr.LarghezzaMks
		, rlpkr.LunghezzaMks
		, rlpkr.AltezzaMks
		, rlpkr.VolumeMks
	from
		(select distinct  
			PackListRef
		from 
			xMORLRigPackList 
				inner join xMORLRig on xMORLRigPackList.Id_xMORLRig = xMORLRig.Id_xMORLRig
		where 
			xMORLRig.Id_xMORL = @Id_xMORL
		) as rlrpl 
			left join xMORLPackListRef rlpkr on rlrpl.PackListRef = rlpkr.PackListRef
	where 
		rlpkr.Id_xMORL = @Id_xMORL
)
go

create function xmofn_xMORLRigPackingList_GetNew (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
) returns varchar(20) 
/*ENCRYPTED*/
as begin
	
	-- prendere l'ultimo valore inserito in PK 
	declare @PKLast varchar(20) = (select max(PackListRef) from xMORLRigPackList where Id_xMORLRig in (
									select Id_xMORLRig from xMORLRig where Id_xMORL = @Id_xMORL)
									) 
	-- se è null lo metto a 0 altrimenti non riesce ad incrementare il valore null 
	if(@PKLast is null) Or (isnumeric(@PKLast) = 0)
		set @PKLast = 0

	-- lo incremento generandone uno nuovo
	set @PKLast = @PKLast + 1

	set @PKLast = (select right('000' + ltrim(rtrim(str(@PKLast))), 3))

	return @PKLast

end
go

-- Restituisce l'elenco degli inverntari aperti o un solo inventario di testa
create function xmofn_xMOIN_Aperti(
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_xMOIN		int
) returns table 
/*ENCRYPTED*/
as return (
	select 
		i.Id_xMOIN
		, i.Terminale
		, i.Cd_Operatore
		, i.Descrizione
		, i.Cd_MGEsercizio
		, MGES_Descrizione = (select Descrizione from MGEsercizio where Cd_MGEsercizio = i.Cd_MGEsercizio)
		, i.Cd_MG
		, i.Cd_MGUbicazione
		, i.DataOra
	from 
		xMOIN i
	where 
			Stato = 0 -- In compilazione
		And (ISNULL(@Id_xMOIN, '') = '' Or i.Id_xMOIN = @Id_xMOIN)
		-- PER ORA NON FILTRIAMO NULLA!!!
		-- Mostra l'elenco degli Invetari aperti per il terminale o dell'operatore
		-- And (Terminale = @Terminale Or Cd_Operatore = @Cd_Operatore)
)
go

-- Elenco articoli da inventariare per il magazzino selezionato
create function xmofn_xMOINRig_AR (
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)		
	, @Id_xMOIN			int			
	, @Cd_MG			char(5)			
	, @Cd_MGUbicazione	varchar(20)
	, @Id_xMOINRig		int			
) returns table
/*ENCRYPTED*/
as return(

	select 
		 NRow					= ROW_NUMBER() over (order by ir.Cd_AR)	
		, Id_xMOINRig			= ir.Id_xMOINRig
		, Cd_AR					= ir.Cd_AR
		, AR_Descrizione		= ar.Descrizione
		, Cd_MG					= ir.Cd_MG
		, Cd_ARLotto			= ir.Cd_ARLotto
		, Cd_MGUbicazione		= ir.Cd_MGUbicazione
		, Cd_DOSottoCommessa 	= ir.Cd_DOSottoCommessa
		, Quantita				= ir.Quantita				-- Quantità contabile
		, QtaRilevata			= ir.QtaRilevata
		, QtaRettifica			= ir.QtaRilevata - ir.Quantita
		, Cd_ARMisura			= upper(ir.Cd_ARMisura)
		, FattoreToUM1			= ir.FattoreToUM1		-- Sempre 1 perché quello UM principale (per sviluppi futuri)
		, Completato			= cast(0 as bit)		-- Vero quando nel client viene impostato come completato dall'operatore (la riga si nasconde)
	From 
		xMOINRig ir
			inner join AR on ar.Cd_AR = ir.Cd_AR
	Where 
			ir.Id_xMOIN = @Id_xMOIN
		-- Se passata alla funzione restituisce solo la riga aggiunta!
		And (isnull(@Id_xMOINRig, 0) = 0 Or ir.Id_xMOINRig = @Id_xMOINRig)
		And ir.Cd_MG = @Cd_MG
		And (isnull(@Cd_MGUbicazione, '') = '' Or ir.Cd_MGUbicazione = @Cd_MGUbicazione)
			-- Tutti quelli gestiti attualmente per il client
		And ir.InLavorazione = 1

)
go

create function xmofn_xMOMGEsercizio (
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)		
	, @All				bit
) returns table
/*ENCRYPTED*/
as return(
	select 
		Ordine				= ROW_NUMBER() over(order by DtFine desc)
		, Cd_MGEsercizio	= Cd_MGEsercizio
		, Descrizione		= Descrizione
		, Corrente			= case when Cd_MGEsercizio = mc.Cd_MGEsercizio_C then 1 else 0 end
	from
		MGEsercizio, (select Cd_MGEsercizio_C = dbo.afn_MGEsercizio(getdate())) as mc
	where
			(isnull(@All, 0) = 1) 
			Or 
			-- L'inizio dell'esercizione deve essere minore uguale della data corrente di sistema
			-- La fine dell'esercizione deve essere maggiore uguale della data corrente di sistema meno un anno
			(DtInizio <= (getdate()) And DtFine >= (getdate() - 366))
)
go

-- Giacenza di un articolo in un magazzino
create function xmofn_xMOGiacenza (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_MGEsercizio		char(4)
	, @Cd_MG				char(5)
	, @Cd_AR				varchar(20)
	, @Cd_MGUbicazione		varchar(20)		-- opzionali
	, @Cd_ARLotto			varchar(20)		-- opzionali
	, @Cd_DOSottoCommessa	varchar(20)		-- opzionali
) returns @out table (
	Cd_AR					varchar(20)
	, Descrizione			varchar(80)
	, Cd_ARMisura			char(2)
	, Quantita				numeric(18,8)
	, Cd_ARLotto			varchar(20)
	, Cd_MGUbicazione		varchar(20)
	, Cd_DOSottoCommessa	varchar(20)
)
/*ENCRYPTED*/
as begin

	insert into @out
	select 
		Ar.Cd_AR
		, Ar.Descrizione
		, Cd_ARMisura		= upper(um.Cd_ARMisura) 
		, mgd.Quantita 
		, mgd.Cd_ARLotto
		, mgd.Cd_MGUbicazione
		, mgd.Cd_DOSottoCommessa
	from 
		MGGiacEx(@Cd_MGEsercizio) mgd 
			inner join ARARMisura um on mgd.Cd_AR = um.Cd_AR And um.DefaultMisura = 1
			inner join AR on ar.Cd_AR = mgd.Cd_AR
	where
			mgd.Cd_MG				= @Cd_MG
		And mgd.Cd_AR				= @Cd_AR 
		And (isnull(@Cd_MGUbicazione, '') = '' Or (mgd.Cd_MGUbicazione = @Cd_MGUbicazione))
		And (isnull(@Cd_ARLotto, '') = '' Or (mgd.Cd_ARLotto = @Cd_ARLotto))
		And (isnull(@Cd_DOSottoCommessa, '') = '' Or (mgd.Cd_DOSottoCommessa = @Cd_DOSottoCommessa))

	return
end
go

-- Giacenza di un articolo in un magazzino per l'INVENTARIO
create function xmofn_xMOGiacenza_IN (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_MGEsercizio		char(4)
	, @Cd_MG				char(5)
	, @Cd_AR				varchar(20)
	, @Cd_MGUbicazione		varchar(20)		-- opzionali
	, @Cd_ARLotto			varchar(20)		-- opzionali
	, @Cd_DOSottoCommessa	varchar(20)		-- opzionali
) returns @out table (
	Cd_AR					varchar(20)
	, Descrizione			varchar(80)
	, Cd_ARMisura			char(2)
	, Quantita				numeric(18,8)
	, Cd_ARLotto			varchar(20)
	, Cd_MGUbicazione		varchar(20)
	, Cd_DOSottoCommessa	varchar(20)
	, QtaRilevata			numeric(18,8)
	, QtaRettifica			numeric(18,8)
)
/*ENCRYPTED*/
as begin

	-- L'inventario deve restituire un solo record da inventariale: per lotto, ubicazione e commessa

	declare @Err bit = 0
	-- Controlli
	
	-- Verifica se esiste il magazzino
	if not exists(select * from MG where Cd_MG = @Cd_MG) set @Err = 1
	if not exists(select * from AR where Cd_AR = @Cd_AR) set @Err = 1

	if (@Err = 0) begin
		insert into @out
		select 
			Cd_AR
			, Descrizione
			, Cd_ARMisura			= upper(Cd_ARMisura)
			, Quantita 
			, Cd_ARLotto
			, Cd_MGUbicazione
			, Cd_DOSottoCommessa
			, QtaRilevata			= cast(0 as numeric(18,8))
			, QtaRettifica			= cast(null as numeric(18,8))
		from 
			dbo.xmofn_xMOGiacenza(@Terminale, @Cd_Operatore, @Cd_MGEsercizio, @Cd_MG, @Cd_AR, @Cd_MGUbicazione, @Cd_ARLotto, @Cd_DOSottoCommessa) mgd
		where
				isnull(mgd.Cd_MGUbicazione, '')			= isnull(@Cd_MGUbicazione, '')
			And isnull(mgd.Cd_ARLotto, '')				= isnull(@Cd_ARLotto, '')
			And isnull(mgd.Cd_DOSottoCommessa, '')		= isnull(@Cd_DOSottoCommessa, '')

		-- Se non esiste giacenza di magazzino restituisco un record con giacenza 
		if not exists(select * from @out) begin
			insert into @out (Cd_AR, Descrizione, Cd_ARMisura, Quantita, Cd_ARLotto, Cd_MGUbicazione, Cd_DOSottoCommessa)
			select 
				Ar.Cd_AR
				, Ar.Descrizione
				, Cd_ARMisura		= upper(um.Cd_ARMisura) 
				, Quantita			= 0
				, @Cd_ARLotto
				, @Cd_MGUbicazione
				, @Cd_DOSottoCommessa
			from 
				AR 
					inner join ARARMisura um on AR.Cd_AR = um.Cd_AR And um.DefaultMisura = 1
			where
				Ar.Cd_AR = @Cd_AR
		end
	end

	return
end
go

-- Elenco Spedizioni
create function xmofn_xMOCodSpe (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Filtro			varchar(100)
	, @Ordinamento		smallint	-- 0 = Codice Spedizione 1 = Data Spedizione
) returns table
/*ENCRYPTED*/
as return (

	Select
		Ordinamento = ROW_NUMBER() Over(Order by case when @Ordinamento = 0 then null else xMOCodSpe.Data end, xMOCodSpe.Cd_xMOCodSpe) 
		--  Dati di testa
		, DOTes.Id_DOTes
		, DOTes.Cd_DO
		, DOTes.Cd_CF
		, DOTes.Cd_CFDest
		, DOTes.NumeroDoc
		, DOTes.DataDoc
		, DOTes.Cd_MGEsercizio
		, DOTes.DataConsegna
		, DOTes.xCd_xMOCodSpe
		, DOTes.xTarga
		, DOTes.NotePiede
		, DataSpedizione		= xMOCodSpe.Data
		-- Elenco documenti generabili
		, Cd_DOs				= (SELECT STUFF((SELECT distinct ',' + DODOPrel.Cd_DO FROM DODOPrel inner join dbo.xmofn_DO(@Terminale, @Cd_Operatore) DO on DODOPrel.Cd_DO = DO.Cd_DO  Where DODOPrel.Cd_DO_Prelevabile = DOTes.Cd_DO FOR XML PATH ('')), 1, 1, '')) 
		, PrelevatoDa			= (select top 1 rl.Cd_DO + ' MOOVI [' + ltrim(rtrim(str(rl.Id_xMORL))) + '] del ' + convert(varchar(10), rl.DataDoc, 105) + ' (' + rl.Cd_Operatore + ')'  from xMORL rl inner join xMORLPrelievo rlp on rl.Id_xMORL = rlp.Id_xMORL where rlp.Id_DOTes = DOTes.Id_DOTes And rl.Stato = 0)
	From
		DOTes
			inner join DO on DOTes.Cd_DO = DO.Cd_DO
			inner join xMOCodSpe on DOTes.xCd_xMOCodSpe = xMOCodSpe.Cd_xMOCodSpe
	Where 
		-- Tipo documento incluso in tutti Doc Prelevabili di documenti Attivi per MOOVI
		DOTes.Cd_DO in (select Distinct
							DODOPrel.Cd_DO_Prelevabile 
						from 
							DODOPrel inner join dbo.xmofn_DO(@Terminale, @Cd_Operatore)	DO	on DODOPrel.Cd_DO = DO.Cd_DO
						where 
							(DODOPrel.Cd_DO = DO.Cd_Do)
						) 
		-- Esecutivo
		And DOTes.Esecutivo	= 1
		-- Prelevabile
		And DOTes.Prelevabile = 1
		-- Con righe evadibili ( = 0 se completamente evaso )
		And DOTes.RigheEvadibili > 0
		-- Con xMOCodSpedizione definita
		And isnull(DOTes.xCd_xMOCodSpe, '') <> ''
		-- Documento gestito dall'Operatore 
		And DOTes.Cd_DO in (select Cd_DO from xmovs_DOOperatore where Cd_Operatore = @Cd_Operatore)
		-- Documento gestito da tutti i terminali o Terminale abilitato
		And ((DO.xMOTerminali is null) OR (@Terminale in (select Terminale from xmovs_DOTerminale)))
		-- Liste di carico non utilizzabili perché inserire in doc non chiusi
		-- And DOTes.xMOCodSpedizione not in (select xMOCodSpedizione From xMORL Where Stato <> 2) 
		-- Filtro
		And xCd_xMOCodSpe in (select Cd_xMOCodSpe from xMOCodSpe where Attiva = 1)
		And
			(
				(isnull(@Filtro, '') = '')  
				Or 
				(xCd_xMOCodSpe like ('%' + @Filtro + '%'))
			)
)
go

-- Elenco Spedizioni Attive (nei documenti) raggruppate per xMOCodSpe
create function xmofn_xMOCodSpe_Search (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Filtro			varchar(100)
) returns table
/*ENCRYPTED*/
as return (

	Select 
		Cd_xMOCodSpe		= xMOCodSpe.Cd_xMOCodSpe
		, Descrizione		= xMOCodSpe.Descrizione
		, NDocs				= Count(*)
	From
		dbo.xmofn_xMOCodSpe(@Terminale, @Cd_Operatore, @Filtro, 0) sp
			inner join xMOCodSpe on sp.xCd_xMOCodSpe = xMOCodSpe.Cd_xMOCodSpe
	Group By
		xMOCodSpe.Cd_xMOCodSpe
		, xMOCodSpe.Descrizione
)
go

-- Elenco documenti aperti
create function xmofn_DOAperti (
  	@Terminale		varchar(39)
  	, @Cd_Operatore	varchar(20)
	, @Filtro		varchar(100)
) returns @out table (
	Ordine					int 
	, Tipo					char(2)
	, Id_xMORL				int
	, Id_xMOTR				int
	, Stato					smallint
	, Cd_DO					char(3)
	, xCd_xMOProgramma		char(2)
	, Ciclo					char(2)
	, DO_Descrizione		varchar(60)
	, Cd_CF					char(7)
	, Cd_CFDest				char(3)
	, CF_Descrizione		varchar(80)
	, DataDoc				smalldatetime
	, Cd_xMOLinea			varchar(20)
	, NumeroDocRif			varchar(20)
	, DataDocRif			smalldatetime
	, Cd_MG_P				char(5)
	, Cd_MG_A				char(5)
	, CodSpedizione			varchar(15)
	, Targa					varchar(20)
	, Cd_DOCaricatore		char(3)
	, F_Doc					varchar(30)
	, P_Do					varchar(max)
	, P_DoN					int
	, R_Tot					int
	, ListenerErrore		varchar(max)
) 
/*ENCRYPTED*/
begin
	-- RL Aperte
	insert into @out
	select
		Ordine = ROW_NUMBER() over(order by r.ts) 
		, Tipo				= 'RL'
		, r.Id_xMORL
		, Id_xMOTR			= null
		, r.Stato
		, r.Cd_DO
		, do.xCd_xMOProgramma
		, vs.Ciclo			
		, vs.DO_Descrizione
		, r.Cd_CF
		, r.Cd_CFDest
		, CF_Descrizione	= cf.Descrizione
		, r.DataDoc
		, r.Cd_xMOLinea
		, r.NumeroDocRif
		, r.DataDocRif
		, r.Cd_MG_P
		, r.Cd_MG_A
		, r.Cd_xMOCodSpe
		, r.Targa
		, r.Cd_DOCaricatore
		-- Filtro documenti
		, F_Doc				 = (r.Cd_DO + ' ' + r.Cd_CF + ' ' + CONVERT(varchar(10), r.DataDoc, 105))
		-- Elenco id documenti prelevati
		, P_Do				 = (SELECT STUFF((SELECT ', ' + rtrim(ltrim(Id_DOTes)) FROM (select distinct Id_xMORL, Id_DOTes from xMORLPrelievo Where Id_xMORL = r.Id_xMORL) d FOR XML PATH ('')), 1, 1, ''))
		-- Numero documenti prelevati
		, P_DoN				 = (SELECT count(*) FROM (select distinct Id_xMORL, Id_DOTes from xMORLPrelievo Where Id_xMORL = r.Id_xMORL) d)
		-- Numero righe lette
		, R_Tot				 = (SELECT count(*) FROM xMORLRig Where Id_xMORL = r.Id_xMORL) 
		-- Eventuale messaggio della coda del listener (0 = Ancora da eseguire, 1 = Eseguito, 2 = Annullato, 3 = Errore)
		, ListenerErrore	 = (SELECT top 1 
										'[' + cast(DataOra as varchar(20)) + '] ' + dbo.xmofn_xMOListenerCoda_Stato(Stato)
										+ case when Stato = 3 then Esito else '' end -- Se nella coda c'è un errore ne mostra il messaggio
								FROM xMOListenerCoda Where Id_xMORL = r.Id_xMORL order by Id_xMOListenerCoda desc)
	from
         	xMORL r
			inner join xmofn_DO(@Terminale, @Cd_Operatore) vs  on vs.Cd_DO = r.Cd_DO
			inner join CF		cf	on r.Cd_CF = cf.Cd_CF
			inner join DO		do	on r.Cd_DO = do.Cd_DO
	where
         		isnull(r.Id_DOTes, 0) = 0
		And r.Stato in (0, 1)	-- In compialzione o Da storicizzare 
		And (r.Cd_Operatore = @Cd_Operatore or r.Terminale = @Terminale)
		And
			(
				isnull(@Filtro, '') = '' 
				Or  
					(
						r.Cd_DO			like('%' + @Filtro + '%') 
						Or
						r.DataDoc		like('%' + @Filtro + '%') 
						Or  
						r.Id_xMORL		like('%' + @Filtro + '%')
						Or                                                                  
						r.Cd_CF			like('%' + @Filtro + '%')
						Or
						r.Cd_CFDest		like('%' + @Filtro + '%')
						Or
						cf.Descrizione	like('%' + @Filtro + '%')
					)
			)
	-- TR Aperte
	insert into @out
	select
		Ordine = 0 -- sempre il primo 
		, Tipo					= 'TR'
		, Id_xMORL				= null
		, t.Id_xMOTR
		, t.Stato
		, Cd_DO					= null
		, xCd_xMOProgramma		= Cd_xMOProgramma		
		, Ciclo					= null
		, Descrizione			= t.Descrizione
		, Cd_CF					= ''
		, Cd_CFDest				= ''
		, CF_Descrizione		= ''
		, t.DataMov
		, Cd_xMOLinea			= null
		, NumeroDocRif			= null
		, DataDocRif			= null
		, Cd_MG_P
		, Cd_MG_A
		, CodSpedizione			= null
		, Targa					= null
		, Cd_DOCaricatore		= null
		, F_Doc					= Cd_xMOProgramma -- in base al programma (TI o SM)
		, P_Do					= null
		, P_DoN					= 0
		, R_Tot					= (SELECT count(*) FROM xMOTRRig_A Where Id_xMOTR = t.Id_xMOTR) 
		-- Eventuale messaggio della coda del listener (0 = Ancora da eseguire, 1 = Eseguito, 2 = Annullato, 3 = Errore)
		, ListenerErrore	 = (SELECT top 1 
										'[' + cast(DataOra as varchar(20)) + '] ' + dbo.xmofn_xMOListenerCoda_Stato(Stato) 
										+ case when Stato = 3 then Esito else '' end -- Se nella coda c'è un errore ne mostra il messaggio
								FROM xMOListenerCoda Where Id_xMOTR = t.Id_xMOTR order by Id_xMOListenerCoda desc)
	from
         	xMOTR t
	where
         		isnull(t.Id_MgMovInt, 0) = 0
		And t.Stato in (0, 1) -- in compilazione o storicizzato
		And t.Cd_Operatore = @Cd_Operatore
		And t.Terminale = @Terminale
		And
			(
				isnull(@Filtro, '') = '' 
				Or  
					(
						'TI'			like('%' + @Filtro + '%') 
						Or
						t.DataMov		like('%' + @Filtro + '%') 
						Or  
						t.Id_xMOTR		like('%' + @Filtro + '%')
						Or                                                                  
						t.Descrizione	like('%' + @Filtro + '%')
					)
			)

	return 
end
go

-- Elenco documenti ristampabili
create function xmofn_DORistampa (
  	@Terminale		varchar(39)
  	, @Cd_Operatore	varchar(20)
	, @Filtro		varchar(100)
) returns table
/*ENCRYPTED*/
as return (

        select 
           Id_DOTes				= dt.Id_DOTes
		, Id_xMORL				= r.Id_xMORL
           , Cd_DO					= dt.Cd_DO
		, DO_Descrizione		= do.Descrizione
           , Cd_CF					= r.Cd_CF
		, CF_Descrizione		= cf.Descrizione
           , Cd_CFDest				= r.Cd_CFDest
		, CFDest_Descrizione	= de.Descrizione
           , DataDoc				= r.DataDoc
           , Cd_xMOLinea			= r.Cd_xMOLinea
           , NumeroDocRif			= r.NumeroDocRif
           , DataDocRif			= r.DataDocRif
           , Targa					= r.Targa
         from
         	xMORL r
         		inner join DOTes	dt	on r.Id_DOTes = dt.Id_DOTes
			inner join CF		cf	on dt.Cd_CF = cf.Cd_CF
			left join CFDest	de	on dt.Cd_CF = de.Cd_CF And dt.Cd_CFDest = de.Cd_CFDest
			inner join DO		do	on dt.Cd_DO = do.Cd_DO
         where
         		isnull(r.Id_DOTes, 0) > 0	-- Documenti chiusi
		And r.Stato = 2 -- Posso ristampare solo documenti storicizzati
		And (r.Cd_Operatore = @Cd_Operatore or r.Terminale = @Terminale)
		And
			(
				-- Se il filtro è nullo mostra solo i documenti creati oggi
				(isnull(@Filtro, '') = '' And dt.DataDoc >= (dbo.afn_Datetime2Date(GETDATE() -1)))
				Or  
				(isnull(@Filtro, '') <> '' And 
				-- Se il filtro non è nullo esegue un like su i campi utili alla ricerca ma degli ultimi 2 anni
					(
						r.Cd_DO			like('%' + @Filtro + '%') 
						Or
						r.DataDoc		like('%' + @Filtro + '%') 
						Or
						dt.Id_DOTes		like('%' + @Filtro + '%')
						Or  
						r.Id_xMORL		like('%' + @Filtro + '%')
						Or                                                                  
						r.Cd_CF			like('%' + @Filtro + '%')
						Or
						r.Cd_CFDest		like('%' + @Filtro + '%')
						Or
						cf.Descrizione	like('%' + @Filtro + '%')
					)
				)
			)
)
go

-- Funzione che restituisce la configurazione del o dei Bc esclusi i tipi SSCC 
-- funzione utilizzata nelle pagina pgAA e pgINM2Rig
create function xmofn_xMOBarcode(
	@Cd_xMOBC char(10)
) returns table 
/*ENCRYPTED*/
as return (
	Select 
		OrdineBC		= cast(Dense_rank() OVER(order by t.Cd_xMOBC) as int)
		, t.Cd_xMOBC
		, Posizione		= cast(Dense_rank() OVER(order by t.Cd_xMOBC) as int)
		, t.Tipo
		, Cd_Tipo		= case t.Tipo
								when 1 then 'GS1'
								when 2 then 'SSCC'
								when 3 then 'STD'
							end
		, t.Detail
		, t.Descrizione
		, Codice		= case t.Tipo
								-- STD
								when 3 then 
									'X' + case when isnull(r.Codice, '') <> '' then r.Codice else ltrim(rtrim(str(row_number() over(order by t.Cd_xMOBC, r.Ordine)))) end	
								-- GS1 o SSCC
								else
									'X' + isnull(r.Codice, 'XXXX' + ltrim(rtrim(str(row_number() over(order by t.Cd_xMOBC, r.Ordine)))))	-- Il nome del codice contiene 01 - 15 ecc il parser json interpreta male i numeri inserendoli in parentesi quadre tipo [15] (cosa che non avviene per 01) il valore X viene elimianto dal client
							end
		, AI			= case when ltrim(rtrim(r.Codice)) = '' then null else ltrim(rtrim(r.Codice)) end
		, r.Ordine
		, r.CampoDb
		, r.LunghezzaMin
		, r.LunghezzaMax
	From
		xMOBCCampo r
			Inner Join 	xMOBC	t	On r.Cd_xMOBC = t.Cd_xMOBC
	where
			--t.Tipo <> 2 And
		(isnull(@Cd_xMOBC, '') = '' or r.Cd_xMOBC = @Cd_xMOBC)
)
go 

-- Barcode per il documento specificato
create function xmofn_DOBarcode(
	@Terminale varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Cd_DO		char(3)					-- Documento da generare
)
returns @out table 
(
	OrdineBC			int					-- Ordinamento del Barcode padre
	,	Cd_xMOBC		char(10)
	,	Posizione		int
	,	Tipo			int
	,	Cd_Tipo			varchar(4)
	,	Detail			bit
	,	Descrizione		varchar(50)
	,	Codice			char(5)
	,	AI				varchar(5)
	,	Ordine			int					-- Ordinamento del campo del Barcode (figlio)
	,	CampoDb			varchar(50)
	,	LunghezzaMin	int
	,	LunghezzaMax	int
)
/*ENCRYPTED*/
as begin
	-- Campo xml contentente i barcode associati al documento da generare
	Declare @xMOBarcode xml
	Set @xMOBarcode = (Select xMOBarcode From DO Where Cd_DO = @Cd_DO)

	-- Tabella di appoggio per la gestione dei barcode
	Declare @xml Table (Riga int, Codice char(10), Attivo bit, Posizione int)
	Insert Into @xml
	Select 
			Riga		= row_number() over(order by col.value('@attivo'	, 'bit'))
		,	Codice		= col.value('@codice'	, 'char(10)')
		,	Attivo		= col.value('@attivo'	, 'bit'			)
		,	Posizione	= col.value('@posizione', 'int'			)
	From 
			@xMOBarcode.nodes('/rows/row') as tbl(col)
	Order By
		Posizione asc

	-- Insert nella tabella di ritorno
	Insert Into @out(OrdineBC, Cd_xMOBC, Posizione, Tipo, Cd_Tipo, Detail, Descrizione, Codice, AI, Ordine, CampoDb, LunghezzaMin, LunghezzaMax)
	Select 
		OrdineBC		= dense_rank() over(order by x.Riga, x.Posizione, t.Cd_xMOBC)
		, t.Cd_xMOBC		
		, x.Posizione
		, t.Tipo
		, Cd_Tipo		= case t.Tipo
								when 1 then 'GS1'
								when 2 then 'SSCC'
								when 3 then 'STD'
							end
		, t.Detail
		, t.Descrizione
		, Codice		= case t.Tipo
								-- STD
								when 3 then 
									'X' + case when isnull(r.Codice, '') <> '' then r.Codice else ltrim(rtrim(str(row_number() over(order by t.Cd_xMOBC, r.Ordine)))) end	
								-- GS1 o SSCC
								else
									'X' + isnull(r.Codice, 'XXXX' + ltrim(rtrim(str(row_number() over(order by t.Cd_xMOBC, r.Ordine)))))	-- Il nome del codice contiene 01 - 15 ecc il parser json interpreta male i numeri inserendoli in parentesi quadre tipo [15] (cosa che non avviene per 01) il valore X viene elimianto dal client
							end
		, AI			= case when ltrim(rtrim(r.Codice)) = '' then null else ltrim(rtrim(r.Codice)) end
		, r.Ordine
		, r.CampoDb
		, r.LunghezzaMin
		, r.LunghezzaMax
	From
		xMOBCCampo r
			Inner Join 	xMOBC	t	On r.Cd_xMOBC = t.Cd_xMOBC
			Inner Join	@xml	x	On x.Codice = r.Cd_xMOBC And x.Attivo = 1
	Order By
		x.Posizione
		,	t.Cd_xMOBC
		,	r.Ordine Asc
	return
end
go


-- Letture (ragruppate per articolo e Um) della rilevazione (a parità di Id_xMORL) eseguite con il residuo se esiste un prelievo
create function xmofn_xMORLRig_AR_Std(
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_xMORL		int				-- Elenco degli id_dotes selezionati per il prelievo
) returns @out table (
	Ordinamento			int
	, Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, ExtField			varchar(20)
	, Cd_ARMisura		char(2)
	, Quantita			numeric(18, 8)
	, QtaEvadibile		numeric(18, 8)
	, QtaResidua		numeric(18, 8)
	, Cd_ARMisura_Def	char(2)
	, FuoriLista		bit
	, Prelievo			bit
	, Ultima			int
) 
/*ENCRYPTED*/
as begin

	declare @EsistePrelievo bit
	declare @Cd_AR_Last varchar(20)

	-- recupera l'ultimo articolo dell'ultima lettura eseguita
	set @Cd_AR_Last = (select top 1 with ties Cd_AR from xMORLRig where Id_xMORL = @Id_xMORL order by row_number() over(order by DataOra desc))

--	--, Cd_ARLotto
--	--, AR_Descrizione
	insert into @out (Ordinamento, Cd_AR, Descrizione, Cd_ARMisura, Cd_ARMisura_Def, ExtField, QtaEvadibile, Quantita, Prelievo, Ultima)
	select 
		Ordinamento			= ROW_NUMBER() 
									over (
										-- Per prima sempre l'ultima lettura eseguita
										order by r.Ultima desc
										-- Per prime sempre le letture con quantità residua > 0
										, case when (case when isnull(r.QtaEvadibile, 0) > 0 then r.QtaEvadibile - isnull(r.Quantita, 0) else 0 end) = 0 then 1 else 0 end
										-- Letture con campi Ext
										, ExtField 
										-- Per data ora lettura (in alto sempre gli ultiumi letti)
										, r.DataOra asc
										-- Per codice articolo
										, r.Cd_AR
									)
		, Cd_AR				= r.Cd_AR
		, Descrizione		= ar.Descrizione
		--, Cd_ARLotto
		, Cd_ARMisura		= upper(r.Cd_ARMisura)
		--, FattoreToUM1		= r.FattoreToUM1
		, Cd_ARMisura_Def	= upper(AR.Cd_ARMisura)
		, ExtField			= r.ExtField
		, QtaEvadibile		= r.QtaEvadibile 
		, Quantita			= r.Quantita
		, Prelievo			= r.Prelievo
		, Ultima			= r.Ultima
	from (	
		-- Somme le quantità per avere una sola riga di articolo 
		select
			Cd_AR
			--, AR_Descrizione
			--, Cd_ARLotto
			, Cd_ARMisura
			--, FattoreToUM1  
			, ExtField
			, QtaEvadibile		= sum(QtaEvadibile)
			, Quantita			= sum(Quantita)
			, Prelievo			= max(cast(Prelievo as int))
			, Ultima			= max(Ultima)
			, DataOra			= max(DataOra)
		from 
			(
			-- Righe del prelievo
			select 
				Tipo = 'P'
				, DORig.Cd_AR
				, DORig.Cd_ARMisura
				, ExtField			= null
				, QtaEvadibile		= DORig.QtaEvadibile
				, Quantita			= cast(0 as numeric(18, 8))
				, Prelievo			= cast(1 as bit)
				, DataOra			= cast(null as smalldatetime)
				, Ultima			= cast(0 as int)
			From 
				DORig 
					inner join xMORLPrelievo on DORig.Id_DORig = xMORLPrelievo.Id_DORig
					inner join ar on ar.Cd_AR = DORig.Cd_AR
			Where 
				-- Righe non evase
				DORig.QtaEvadibile > 0
				-- Prelievo del doc corrente
			And xMORLPrelievo.Id_xMORL = @Id_xMORL
			union all
			-- Righe delle letture
			Select 
				Tipo = 'L'
				, rlr.Cd_AR
				, rlr.Cd_ARMisura
				, ExtField			= null
				, QtaEvadibile		= cast(0 as numeric(18, 8))
				, Quantita			= Quantita
				, Prelievo			= cast(0 as bit)
				, DataOra			= DataOra
				, Ultima			= cast(case when rlr.Cd_AR = @Cd_AR_Last then 1 else 0 end as int)
			From 
				xMORLRig rlr
					inner join ar on ar.Cd_AR = rlr.Cd_AR
			where
				Id_xMORL = @Id_xMORL
			) r0
		group by 
			Cd_AR
			--, AR_Descrizione
			--, Cd_ARLotto
			, ExtField
			, Cd_ARMisura
			--, FattoreToUM1
	) r
		inner join AR on AR.Cd_AR = r.Cd_AR

	--declare @x xml = (select * from @out for xml path(''))

	-- se sono state inserite righe esiste il prelievo
	set @EsistePrelievo = case when exists(select * from @out where Prelievo = 1) then 1 else 0 end

	-- Aggiorna i residui di tutti i record
	update @out set
		QtaResidua		= case when isnull(QtaEvadibile, 0) > 0 then QtaEvadibile - isnull(Quantita, 0) else 0 end
		, FuoriLista	= case when @EsistePrelievo = 1 And isnull(QtaEvadibile, 0) = 0 then 1 else 0 end

	return
end
go
create function xmofn_xMORLRig_AR (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_xMORL		int				-- Elenco degli id_dotes selezionati per il prelievo
) returns @out table (
	Ordinamento			int
	, Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, ExtField			varchar(20)
	--, Cd_ARLotto		varchar(20)
	, Cd_ARMisura		char(2)
	, Quantita			numeric(18, 8)
	, QtaEvadibile		numeric(18, 8)
	, QtaResidua		numeric(18, 8)
	--, FattoreToUM1		numeric(18, 8)		-- Tolto e inglobato nei calcoli in quanto generava confusione nell'UI di Moovi e separava le righe
	, Cd_ARMisura_Def	char(2)
	, FuoriLista		bit
	, Prelievo			bit
	, Ultima			int
) as begin
	if object_id('xmofn_xMORLRig_AR_Usr') is null
		insert into @out select * from dbo.xmofn_xMORLRig_AR_Std(@Terminale, @Cd_Operatore, @Id_xMORL)
	else
		insert into @out select * from dbo.xmofn_xMORLRig_AR_Usr(@Terminale, @Cd_Operatore, @Id_xMORL)
	return 
end
go
	
create function xmofn_xMORLRig_Totali (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_xMORL		int				-- Elenco degli id_dotes selezionati per il prelievo
) returns @out table (
	Id_xMORL		int
	, RLRig_Tot		int		-- Totale delle letture effettuate
	, Prelievo		bit		-- Vero se esiste il prelievo
	, Ar_Totali		int		-- Articoli tolali letti
	, Ar_Prelievo	int		-- Articoli totali inclusi nel prelievo (se Prelievo = 1)
	, Ar_NonCongrui int		-- Articoli che non hanno quantità diverse dalla quantità totale richiesta (se Prelievo = 1)
	, Ar_Fuorilista int		-- Articoli fuorilista (se Prelievo = 1)
) 
/*ENCRYPTED*/
as begin

	insert into @out (Id_xMORL, RLRig_Tot, Prelievo, Ar_Totali)
	select 
		Id_xMORL		= @Id_xMORL
		, RLRig_Tot		= (select isnull(count(*), 0) from (select Id_xMORL from xMORLRig where Id_xMORL = @Id_xMORL) as r)
		, Prelievo		= case when exists(select * from xMORLPrelievo where Id_xMORL = @Id_xMORL) then 1 else 0 end
		, Ar_Totali		= (select isnull(count(*), 0) from (select Cd_AR from xMORLRig where Id_xMORL = @Id_xMORL group by Cd_AR) as t)
	from 
		xMORL 
	where
		Id_xMORL = @Id_xMORL

	-- Aggiorna il totale di articoli inseriti nei prelievi
	update @out set 
		Ar_Prelievo = (select isnull(count(*), 0) from (select DORig.Cd_AR from xMORLPrelievo inner join DORig On xMORLPrelievo.Id_DORig = DORig.Id_DORig where Id_xMORL = @Id_xMORL group by DORig.Cd_AR) as p)

	-- Aggiorna il totale degli articoli incompleti (QtaResidua < Qta letta)
	update @out set 
		Ar_NonCongrui = (select isnull(count(*), 0) from (select Cd_AR from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Quantita <> QtaEvadibile) as i)

	update @out set 
		Ar_Fuorilista = (select isnull(count(*), 0) from (select Cd_AR from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where FuoriLista = 1) as f)

	return
end
go

-- Informazioni sulle letture e su gli articoli completi e incompleti del prelievo di xMORLRig
create function xmofn_xMORLRig_Info_Letture_AR(	
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int 
) returns table
/*ENCRYPTED*/
as return (

	select 
		Letture					= (Select count(*) From xMORLRig Where Id_xMORL = @Id_xMORL)
		, ArticoliIncompleti	= (select count(*) from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And QtaResidua > 0)
		, ArticoliCompleti		= (select count(*) from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And QtaResidua = 0)	
)
go

create function xmofn_xMOMGDisp (
	  @Terminale varchar(39)
	, @Cd_Operatore			varchar(20)
	, @Cd_AR				varchar(20) 
	, @Cd_MG				char(5)
	, @Cd_MGUbicazione		varchar(20)
	, @Cd_ARLotto			varchar(20)
	, @Cd_DOSottoCommessa	varchar(20)
	, @QtaPositiva			bit
) returns @out table (
	  Ordinamento			int
	, Cd_MG				char(5)
	, Cd_MGUbicazione	varchar(20)
	, Cd_AR				varchar(20)
	, Descrizione		varchar(80)
	, Cd_ARMisura		char(2)
	, Quantita			numeric(18,8)
	, QuantitaDisp		numeric(18,8)
	, QuantitaDimm		numeric(18,8)
	, Cd_ARLotto		 varchar(20)
	, Cd_DOSottoCommessa varchar(20)
)
/*ENCRYPTED*/
as begin
	
	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	insert into @out
	select top 1000			-- ATTENZIONE AL TOP !! NON VA BENE
		Ordinamento			 = row_number() over(partition by D.Cd_MG, D.Cd_MGUbicazione order by D.Cd_AR)
		, Cd_MG				 = D.Cd_MG
		, Cd_MGUbicazione	 = D.Cd_MGUbicazione
		, Cd_AR				 = AR.Cd_AR
		, Descrizione		 = AR.Descrizione
		, Cd_ARMisura		 = AR.Cd_ARMisura
		, Quantita			 = D.Quantita
		, QuantitaDisp		 = D.QuantitaDisp
		, QuantitaDimm		 = D.QuantitaDimm
		, Cd_ARLotto		 = D.Cd_ARLotto
		, Cd_DOSottoCommessa = D.Cd_DOSottoCommessa
	from
		MGDispEx(@Cd_MGEsercizio) D
		Inner Join AR         On D.Cd_AR	= AR.Cd_AR
	where 
			((isnull(@Cd_MG, '') = '') OR D.Cd_MG = @Cd_MG)
		AND ((isnull(@Cd_MGUbicazione, '') = '') OR D.Cd_MGUbicazione = @Cd_MGUbicazione)
		AND ((isnull(@Cd_AR, '') = '') OR D.Cd_AR = @Cd_AR)
		AND ((ISNULL(@Cd_ARLotto, '') = '') OR D.Cd_ARLotto = @Cd_ARLotto)
		AND ((ISNULL(@Cd_DoSottoCommessa , '') = '') OR D.Cd_DoSottoCommessa = @Cd_DOSottoCommessa)
		AND ((isnull(@QtaPositiva, 0) = 0) OR (QuantitaDisp >= 0 AND QuantitaDimm >= 0))
	--order by
	--	Cd_MG
	--	, Cd_MGUbicazione
	--	, Cd_AR
	
	return 
end
go

create function xmofn_UbicazioniCorsia_Get (
	@SoloDefinizione			bit
	, @Cd_MG					char(5)
	, @Cd_xMOMGCorsia			char(5)
	, @Template_Cd_MGUbicazione	varchar(max)
	, @Template_DescUbicazione	varchar(max)
	, @Default_Larghezza		numeric(18,8)
	, @Default_Altezza			numeric(18,8)
	, @Default_Profondita		numeric(18,8)
	, @Default_PesoMaxMks		numeric(18,8)
	, @Default_VolumeMaxMks		numeric(18,8)
	, @Default_Stato			char(1)
) returns @out table (
	Riga					int
	, xMOColonna			int
	, xMORiga				int
	, Cd_MGUbicazione_P		varchar(20)
	, Cd_MGUbicazione		varchar(20)
	, Descrizione			varchar(50)
	, xMOLarghezzaMks		numeric(18,8)
	, xMOAltezzaMks			numeric(18,8)
	, xMOProfonditaMks		numeric(18,8)
	, xMOPesoMaxMks			numeric(18,8)
	, xMOVolumeMaxMks		numeric(18,8)
	, xMOStato				char(1)
)
/*ENCRYPTED*/
as begin
	
	if @SoloDefinizione = 1
		return

	-- Identifico se nel template del codice ci sono dei valori da paddare
	declare @cfind_cod as char(4)	-- Tipo di pad identificato per le colonne
	declare @cpad_cod as char(3)	-- Pad da applicare alle colonne
	declare @rfind_cod as char(4)	-- Tipo di pad identificato per le righe
	declare @rpad_cod as char(3)	-- Pad da applicare alle righe

	select @cpad_cod =	case 
							when CHARINDEX('[2C]', @Template_Cd_MGUbicazione) > 0 then '00'
							when CHARINDEX('[3C]', @Template_Cd_MGUbicazione) > 0 then '000'
							else ''
						end
		, @cfind_cod =	case 
							when CHARINDEX('[2C]', @Template_Cd_MGUbicazione) > 0 then '[2C]'
							when CHARINDEX('[3C]', @Template_Cd_MGUbicazione) > 0 then '[3C]'
							else ''
						end
		, @rpad_cod =	case 
							when CHARINDEX('[2R]', @Template_Cd_MGUbicazione) > 0 then '00'
							when CHARINDEX('[3R]', @Template_Cd_MGUbicazione) > 0 then '000'
							else ''
						end
		, @rfind_cod =	case 
							when CHARINDEX('[2R]', @Template_Cd_MGUbicazione) > 0 then '[2R]'
							when CHARINDEX('[3R]', @Template_Cd_MGUbicazione) > 0 then '[3R]'
							else ''
						end

	-- Identifico se nel template della descrizione ci sono dei valori da paddare
	declare @cfind_des as char(4)	-- Tipo di pad identificato per le colonne
	declare @cpad_des as char(3)	-- Pad da applicare alle colonne
	declare @rfind_des as char(4)	-- Tipo di pad identificato per le righe
	declare @rpad_des as char(3)	-- Pad da applicare alle righe

	select @cpad_des =	case 
							when CHARINDEX('[2C]', @Template_DescUbicazione) > 0 then '00'
							when CHARINDEX('[3C]', @Template_DescUbicazione) > 0 then '000'
							else ''
						end
		, @cfind_des =	case 
							when CHARINDEX('[2C]', @Template_DescUbicazione) > 0 then '[2C]'
							when CHARINDEX('[3C]', @Template_DescUbicazione) > 0 then '[3C]'
							else ''
						end
		, @rpad_des =	case 
							when CHARINDEX('[2R]', @Template_DescUbicazione) > 0 then '00'
							when CHARINDEX('[3R]', @Template_DescUbicazione) > 0 then '000'
							else ''
						end
		, @rfind_des =	case 
							when CHARINDEX('[2R]', @Template_DescUbicazione) > 0 then '[2R]'
							when CHARINDEX('[3R]', @Template_DescUbicazione) > 0 then '[3R]'
							else ''
						end

	-- Crea tante righe quante colonne
	declare @Ci int = 1;		-- Colonna inizio
	declare @Cf int = (select Colonne from xMOMGCorsia where Cd_MG = @Cd_MG And Cd_xMOMGCorsia = @Cd_xMOMGCorsia);	-- Colonna fine
	declare @Ri int = 1;		-- Riga inizio
	declare @Rf int = (select Righe from xMOMGCorsia where Cd_MG = @Cd_MG And Cd_xMOMGCorsia = @Cd_xMOMGCorsia);	-- Riga fine

	with C as (
		
		select
			@Ci as Cn
		union all
		select
			Cn + 1
		from
			C
		where
			Cn + 1 <= @Cf
	),
	R as (
		select 
			@Ri as Rn
		union all
		select
			Rn + 1
		from
			R
		where
			Rn + 1 <= @Rf
	)

	insert into @out
	select  
		   Riga						= ROW_NUMBER() over(order by Cn, Rn)
		   , xMOColonna				= Cn
		   , xMORiga				= Rn
		   , Cd_MGUbicazione_P		= LEFT(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																	@Template_Cd_MGUbicazione, '[MG]', ltrim(rtrim(@Cd_MG)))
																, '[COR]', ltrim(rtrim(@Cd_xMOMGCorsia)))
															, @cfind_cod, ltrim(rtrim(right(ltrim(rtrim(@cpad_cod)) + ltrim(rtrim(str(Cn))), len(@cpad_cod)))))
														, '[C]', ltrim(rtrim(str(Cn))))
													, @rfind_cod, ltrim(rtrim(right(ltrim(rtrim(@rpad_cod)) + ltrim(rtrim(str(Rn))), len(@rpad_cod)))))
												, '[R]', ltrim(rtrim(str(Rn))))
											, 20)
			, Cd_MGUbicazione		= null
			, Descrizione			= LEFT(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																	@Template_DescUbicazione, '[MG]', ltrim(rtrim(@Cd_MG)))
																, '[COR]', ltrim(rtrim(@Cd_xMOMGCorsia)))
															, @cfind_cod, ltrim(rtrim(right(ltrim(rtrim(@cpad_cod)) + ltrim(rtrim(str(Cn))), len(@cpad_cod)))))
														, '[C]', ltrim(rtrim(str(Cn))))
													, @rfind_cod, ltrim(rtrim(right(ltrim(rtrim(@rpad_cod)) + ltrim(rtrim(str(Rn))), len(@rpad_cod)))))
												, '[R]', ltrim(rtrim(str(Rn))))
											, 50)
			, xMOLarghezzaMks		= @Default_Larghezza
			, xMOAltezzaMks			= @Default_Altezza
			, xMOProfonditaMks		= @Default_Profondita
			, xMOPesoMaxMks			= @Default_PesoMaxMks
			, xMOVolumeMaxMks		= @Default_VolumeMaxMks
			, xMOStato				= @Default_Stato
	from
		C, R
	option (MAXRECURSION 0);

	update @out set
		Cd_MGUbicazione			= MGUbicazione.Cd_MGUbicazione
		, Descrizione			= MGUbicazione.Descrizione
		, xMOLarghezzaMks		= MGUbicazione.xMOLarghezzaMks
		, xMOAltezzaMks			= MGUbicazione.xMOAltezzaMks
		, xMOProfonditaMks		= MGUbicazione.xMOProfonditaMks
		, xMOPesoMaxMks			= MGUbicazione.xMOPesoMaxMks
		, xMOVolumeMaxMks		= MGUbicazione.xMOVolumeMaxMks
		, xMOStato				= MGUbicazione.xMOStato
	from @out o
		inner join MGUbicazione on o.xMOColonna = MGUbicazione.xMOColonna And o.xMORiga = MGUbicazione.xMORiga And MGUbicazione.Cd_MG = @Cd_MG And MGUbicazione.xCd_xMOMGCorsia = @Cd_xMOMGCorsia

	return
end
go

-- Elenco documenti attivi per il prelievo (utili per selezionare gli articoli da stoccaggare)
create function xmofn_xMOTRDoc4Stoccaggio (
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar(20)
	, @Cd_MG_P				char(5)
	, @Cd_MGUbicazione_P	varchar(20)
) returns table 
/*ENCRYPTED*/
as return (
	select 
		*
	from (
		Select 
			--  Dati di testa
			Id_DOTes				= DOTes.Id_DOTes
			, Cd_DO					= DOTes.Cd_DO
			--, DO_Descrizione		= DOTes.DO_Descrizione
			, Cd_CF					= DOTes.Cd_CF
			, CF_Descrizione		= cf.Descrizione
			, Cd_CFDest				= DOTes.Cd_CFDest
			, CFDest_Descrizione	= so.Descrizione
			, NumeroDoc				= DOTes.NumeroDoc
			, DataDoc				= DOTes.DataDoc
			, DataConsegna			= DOTes.DataConsegna
			, Cd_DOSottoCommessa	= DOTes.Cd_DOSottoCommessa
			, NumeroDocRif			= DOTes.NumeroDocRif
			, DataDocRif			= DOTes.DataDocRif
			, Cd_PG					= DOTes.Cd_PG
			-- Campi utili ai Filtri
			, F_Doc					= (dbo.afn_FormatNumeroDoc(DOTes.Cd_DO, DOTes.NumeroDoc, DOTes.DataDoc))
			, F_Cd_ARs				= (SELECT STUFF((SELECT distinct ', ' + Cd_AR FROM DORig Where Id_DOTes = DOTes.Id_DOTes FOR XML PATH ('')), 1, 1, '')) 
			, Cd_DOs				= (SELECT STUFF((SELECT distinct ',' + DODOPrel.Cd_DO FROM DODOPrel inner join dbo.xmofn_DO(@Terminale, @Cd_Operatore) DO on DODOPrel.Cd_DO = DO.Cd_DO  Where DODOPrel.Cd_DO_Prelevabile = DOTes.Cd_DO FOR XML PATH ('')), 1, 1, '')) 
			, N_DORig				= (SELECT COUNT(*) FROM DORig WHERE DORig.Id_DOTes = DOTes.Id_DOTes and QtaEvadibile > 0)
		From
			DOTes
				--inner join	DO														do		on DOTes.Cd_DO = do.Cd_DO
				inner join	CF														cf		on DOTes.Cd_CF = cf.Cd_CF
				left join	CFDest													so		on DOTes.Cd_CF = so.Cd_CF And DOTes.Cd_CFDest = so.Cd_CFDest
		where 
			DOTes.Id_DOTes in (select 
									Id_DOTes 
								from 
									DORig r
										inner join DO d on r.Cd_DO = d.Cd_Do
										left join	MGCausale		mgc	on d.Cd_MGCausale = mgc.Cd_MGCausale
								where 
									d.xMOStoccaggio = 1
									And (
											mgc.MagAFlag = 1 And r.Cd_MG_A = @Cd_MG_P
											OR 
											mgc.MagPFlag = 1 And r.Cd_MG_P = @Cd_MG_P
										)
									And (
											ISNULL(@Cd_MGUbicazione_P, '') = '' 
											Or 
											mgc.MagAFlag = 1 And r.Cd_MGUbicazione_A = @Cd_MGUbicazione_P
											Or
											mgc.MagPFlag = 1 And r.Cd_MGUbicazione_P = @Cd_MGUbicazione_P
										)
									AND DOTes.DataDoc >= GETDATE() -20
			)
	) p
	where
		F_Cd_ARs is not null
)
go

-- Elenco delle righe temporane (comprese quelle stoccate in A)
create function xmofn_xMOTRRig_TA ( 
	@Terminale		varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTR		int
) returns table
/*ENCRYPTED*/
as return (
	select 
		Riga				= row_number() over(order by Id_xMOTRRig_T)
		-- Indica l'ubicazione in cui si trova l'operatore (recuperata dall'ultima riga salvata in arrivo)
		, UBCorrente = isnull((select top 1 with ties case when Cd_MGUbicazione_A = t.Cd_MGUbicazione_A then 1 else 0 end from xMOTRRig_A where Id_xMOTR = @Id_xMOTR order by Id_xMOTRRig_A desc)
						-- Nessuna ubicazione ancora gestita dall'operatore: restituisce la prima delle sequenze
						, case when t.Ordine_Ub = 1 then 1 else 0 end)
		-- Indica l'ultimo articolo stoccato
		, ARCorrente = case when Id_xMOTRRig_A = isnull((select max(Id_xMOTRRig_A) from xMOTRRig_A where Id_xMOTR = @Id_xMOTR), 0) then 1 else 0 end
		, *
	from (
		select 
			-- Ordinamento --> Ub lette sempre in fondo + Articolo + Seq + Ubicazione
			Ordine_Ar			= row_number() over(order by case when Id_xMOTRRig_A is null then 0 else 1 end, Cd_Ar, CPSequenza, Cd_MGUbicazione_A)
			-- Ordinamento --> Ub lette sempre in fondo + Seq + Ubicazione
			, Ordine_Ub			= dense_rank() over(order by case when Id_xMOTRRig_A is null then 0 else 1 end, CPSequenza, Cd_MGUbicazione_A)
			, *
		from (
			select
				-- EX Ordine_Ub = ROW_NUMBER() OVER (Order by case when t.Id_xMOTRRig_A is null then 0 else 1 end, t.Id_xMOTRRig_A desc, t.Cd_MGUbicazione_A)
				--, Ordine convertita 			= ROW_NUMBER() OVER (Order by mgc.CPSequenza, t.Cd_MGUbicazione_A)
				Id_xMOTR			= t.Id_xMOTR
				, Id_xMOTRRig_P		= t.Id_xMOTRRig_P
				, Id_xMOTRRig_A		= t.Id_xMOTRRig_A 
				, Id_xMOTRRig_T		= t.Id_xMOTRRig_T
				, Cd_AR				= p.Cd_AR
				, Descrizione		= ar.Descrizione
				, QtaDaStoccare		= t.QtaUMP - isnull(a.Quantita, 0)
				--, QtaStoccata		= isnull(a.Quantita, 0)
				, Quantita			= case when a.Id_xMOTRRig_A is null then t.QtaUMP				else a.Quantita end 
				, Cd_ARMisura		= case when a.Id_xMOTRRig_A is null then p.Cd_ARMisura			else a.Cd_ARMisura end
				, FattoreToUM1		= case when a.Id_xMOTRRig_A is null then p.FattoreToUM1			else a.FattoreToUM1 end
				, Cd_MG_A			= case when a.Id_xMOTRRig_A is null then t.Cd_MG_A				else a.Cd_MG_A end
				, Cd_MGUbicazione_A	= case when a.Id_xMOTRRig_A is null then t.Cd_MGUbicazione_A	else a.Cd_MGUbicazione_A end
				, CPSequenza		= mgc.CPSequenza
				, Tipo				= t.Tipo		
				, Stato				= case when a.Id_xMOTRRig_A	is null then 'A' else 'S' end
			from 
				xMOTRRig_T						t
					inner join xMOTRRig_P		p on t.Id_xMOTRRig_P = p.Id_xMOTRRig_P
					inner join AR				ar on  p.Cd_AR = ar.Cd_AR
					left join MGUbicazione		mgu on t.Cd_MG_A = mgu.Cd_MG And t.Cd_MGUbicazione_A = mgu.Cd_MGUbicazione
					left join xMOMGCorsia		mgc on t.Cd_MG_A = mgc.Cd_MG And mgu.xCd_xMOMGCorsia = mgc.Cd_xMOMGCorsia
					left join xMOTRRig_A		a on t.Id_xMOTRRig_A = a.Id_xMOTRRig_A
			where
				t.Id_xMOTR = @Id_xMOTR
		) as r	
	) as t
)
go

create function xmofn_ARAlias_ARMisura (
	@Cd_AR			varchar(20) 
	, @Alias		varchar(20)			
) returns char(2)
/*ENCRYPTED*/
as begin
		
	declare @Cd_ARMisura char(2)

	select 
		@Cd_ARMisura = Cd_ARMisura 
	from 
		ARAlias
	where 
		Cd_AR = @Cd_AR
		AND Alias = @Alias

	return @Cd_ARMisura
end
go

create function xmofn_xMORLPrelievo_NotePiede (
	@Id_xMORL int
) returns table
/*ENCRYPTED*/
as return
(
	select distinct
		Cd_DO
		, NumeroDoc
		, NotePiede 
	from 
		DOTes  dt
		right join xMORLPrelievo pr on pr.Id_DOTes = dt.Id_DOTes
	where	
		pr.Id_xMORL = @Id_xMORL
)
go

Create Function xmofn_xMORLRig_GetUbicazione (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
	, @Cd_MG varchar(5)
	, @Cd_AR varchar(20)
	, @Posizione int
)
Returns @out Table (Posizione int, Cd_MGUbicazione varchar(20), Quantita numeric(18,8))
As
Begin
	
	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	-- Inserisco tutte le righe disponibili per l'articolo del magazzino ordinandole per data scadenza lotto, CASequenza, corsia e ubcazione
	insert into @out
	select 
		Posizione				= row_number() over(order by al.DataScadenza, isnull(c.CASequenza, 99999), c.Cd_xMOMGCorsia, u.Cd_MGUbicazione)
		, Cd_MGUbicazione		= mg.Cd_MGUbicazione
		, Quantita				= mg.Quantita
	From
		MGGiacEx(@Cd_MGEsercizio)	mg
			left join MGUbicazione	u	on mg.Cd_MG = u.Cd_MG And mg.Cd_MGUbicazione = u.Cd_MGUbicazione
			left join xMOMGCorsia	c	on u.Cd_MG = c.Cd_MG And u.xCd_xMOMGCorsia = c.Cd_xMOMGCorsia
			left join ARLotto		al	on mg.Cd_ARLotto = al.Cd_ARLotto
	Where 
			mg.Cd_MG = @Cd_MG
		And mg.Cd_AR = @Cd_AR

	-- Aggiorno le quantità sottraendo quelle prelevate dalle rilevazioni aperte
	update @out set
		Quantita = o.Quantita - isnull(rl.Quantita, 0)
	from
		@out o
			left join 
				-- Tutte le quantità sommate per ubicazioni 
				(select Cd_MGUbicazione = isnull(Cd_MGUbicazione_P, Cd_MGUbicazione_A), Quantita = sum(Quantita  * FattoreToUM1) 
					from xMORLRig 
					where 
							Id_xMORL = @Id_xMORL 
						And Cd_AR = @Cd_AR 
						And (isnull(Cd_MG_P, '') = @Cd_MG Or isnull(Cd_MG_A, '') = @Cd_MG) 
					group by Cd_MGUbicazione_P, Cd_MGUbicazione_A
				) as rl on o.Cd_MGUbicazione = rl.Cd_MGUbicazione

	-- Elimino tutte le righe superiori alla prima da restituire
	delete from @out 
	where 
		-- La minima posizione maggiore uguale a quella passata alla funzione con quantità disponibile
		Posizione <> (select min(posizione) from @out where Quantita > 0 And Posizione >= @Posizione)

	return
End
Go

Create Function xmofn_xMORLPrelievo_Azzera (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMORL int
) returns table
/*ENCRYPTED*/
as return
(
	select
		Ordine		= ROW_NUMBER() over(order by r.Cd_AR, r.Descrizione, r.DataConsegna)
		, ArRiga	= ROW_NUMBER() over(partition by r.Cd_AR, r.Descrizione order by r.DataConsegna)
		, NumeroDoc	= dbo.afn_FormatNumeroDoc_ById(r.Id_DOTes)
		, r.Id_DOTes
		, r.Id_DORig
		, r.Riga
		, r.Cd_AR
		, r.Descrizione
		, r.DataConsegna
		, r.NoteRiga
		, r.Cd_ARMisura
		, r.FattoreToUM1
		, r.QtaEvadibile
		, QtaLetta = isnull(rlr.QtaLetta / r.FattoreToUM1, 0)
		, Azzera = cast(0 as bit)
	from
		xMORLPrelievo			p
			inner join DORig	r on p.Id_DORig = r.Id_DORig
			left join (select Id_xMORL, Cd_AR, QtaLetta = sum(rlr.Quantita * FattoreToUM1) From xMORLRig rlr group by Id_xMORL, Cd_AR) as rlr on rlr.Id_xMORL = p.Id_xMORL And rlr.Cd_AR = r.Cd_AR
	where
		p.Id_xMORL = @Id_xMORL

)
Go

create function xmofn_xMOPRBLAttivita (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
) returns table 
/*ENCRYPTED*/
as return (

	select 
		Ordinamento				= row_number() over(order by PROL.DataObiettivo, PRBL.Id_PrBL)
		-- Ordine Lavorazione
		, Id_PrOL				= PROL.Id_PrOL
		, Id_PrOLAttivita		= PROLAttivita.Id_PrOLAttivita
		, OL					= ltrim(rtrim(str(PROL.Numero))) + '/' + ltrim(rtrim(str(PROL.Anno)))
		, Cd_AR					= PROL.Cd_AR
		, PROL.Quantita
		, PROL.QuantitaProdotta
		, PROL.Cd_ARMisura
		, PROL.FattoreToUM1
		, PROL.Cd_DoSottoCommessa
		, PROLAttivita.Descrizione
		, PROLAttivita.Articolo
		, PROLAttivita.PercTrasferita
		-- Bolla Lavorazione
		, Id_PrBL				= PRBL.Id_PrBL
		, Id_PrBLAttivita		= PRBLAttivita.Id_PrBLAttivita	-- Campo per la selezione dei materiali
		, Interno				= cast(~PRRisorsa.Esterno as bit)
		, Trasferita			= cast(PRBLAttivita.Trasferita as bit)
		, Bolla					= ltrim(rtrim(str(PRBL.Numero))) + '/' + ltrim(rtrim(str(PRBL.Anno)))
		, DataObiettivo			= PRBL.DataObiettivo
		, Cd_PrRisorsa			= PRRisorsa.Cd_PrRisorsa
		, Cd_xMOLinea			= PRRisorsa.xCd_xMOLinea
		, NotePrBL				= PRBL.NotePrBL
		, NotePrBLAttivita		= PRBLAttivita.NotePrBLAttivita
		, DaTrasferire			= cast(case when exists(select * from xMOPRTR where xMOPRTR.Id_PrBLAttivita = PRBLAttivita.Id_PrBLAttivita And Stato = 0) then 1 else 0 end as bit)
		, Mancante				= cast(case when exists(select * from PRTRMateriale inner join PRTRAttivita on PRTRMateriale.Id_PRTRAttivita = PRTRAttivita.Id_PrTRAttivita where PRTRAttivita.Id_PrBLAttivita = PRBLAttivita.Id_PrBLAttivita And PRTRMateriale.xMancante = 1) then 1 else 0 end as bit)
	from 
		PRBLEx PRBL
			inner join PrBLAttivitaEx	PrBLAttivita	on PRBL.Id_PrBL = PRBLAttivita.Id_PrBL
			inner join PRRisorsa						on PRBL.Cd_PrRisorsa = PRRisorsa.Cd_PrRisorsa
			inner join PrOLAttivitaEx	PrOLAttivita	on PrOLAttivita.Id_PrOLAttivita = PRBLAttivita.Id_PrOLAttivita
			inner join PrOLEx			PrOL			on PrOL.Id_PrOL = PROLAttivita.Id_PrOL
	where
			PRRisorsa.xCd_xMOLinea is not null
		And PRBL.Esecutivo = 1
		And PRBL.Prodotto = 0
		And PROL.Esecutivo = 1
		And PROL.Sospeso = 0

)
go

create function xmofn_xMOPRTR_QtaTrasferita (
	@Id_PrBLAttivita	int
	, @Id_PrBLMateriale int
	, @FattoreToUM1		numeric(18,8)
) returns numeric(18, 8) 
/*ENCRYPTED*/
as begin

	if isnull(@FattoreToUM1, 0) <= 0	set @FattoreToUM1 = 1;

	declare @QtaUM1 numeric(18,8) = 0;

	-- Trasferimenti da Documenti
	set @QtaUM1 = @QtaUM1 + isnull((
		select 
			QtaTrasferitaUM1	= cast(sum(DORig.Qta * DORig.FattoreToUM1) as numeric(18,8))
		from 
			PRTRAttivita inner join DORig on PRTRAttivita.Id_DoTes_DDT = DORig.Id_DOTes
			, (select Cd_Ar, Cd_ArLotto From PRBLMateriale Where Id_PrBLMateriale = @Id_PrBLMateriale) mt
		where
				Id_PrBLAttivita = @Id_PrBLAttivita 
			AND DoRig.Cd_AR = mt.Cd_AR AND isnull(DoRig.Cd_ARLotto, '') = isnull(mt.Cd_ARLotto, '')), 0)

	-- Trasferimenti da Bolla
	set @QtaUM1 = @QtaUM1 + isnull((
		select 
			QtTtasferitaUM1	= cast(sum(PRTRMateriale.Consumo * PRTRMateriale.FattoreToUM1) as numeric(18,8))
		from 
			PRTRAttivita inner join PRTRMateriale on PRTRAttivita.Id_PrTRAttivita = PRTRMateriale.Id_PrTRAttivita
		where 
			PRTRMateriale.xId_PrBLMateriale = @Id_PrBLMateriale
		), 0)
		
	-- Restituisce la quantità nel fattore richiesto
	return @QtaUM1 / @FattoreToUM1

end
go

-- Elenco articoli trasferiti
create function xmofn_xMOPRTR_QtaDaTrasferire (
	@Id_PrBLAttivita	int
	, @Id_PrBLMateriale int
	, @FattoreToUM1		numeric(18,8)
) returns numeric(18, 8) 
/*ENCRYPTED*/
as begin

	if isnull(@FattoreToUM1, 0) <= 0	set @FattoreToUM1 = 1;

	declare @QtaUM1 numeric(18,8) = 0;

	-- Trasferimenti da Bolla
	set @QtaUM1 = (select cast(sum(xMOPRTRRig.Quantita * xMOPRTRRig.FattoreToUM1) as numeric(18, 8))
					from
						xMOPRTRRig
							inner join xMOPRTR on xMOPRTRRig.Id_xMOPRTR = xMOPRTR.Id_xMOPRTR
					where
							xMOPRTR.Id_PrBLAttivita = @Id_PrBLAttivita
						And Stato = 0
						And xMOPRTRRig.Id_PrBLMateriale = @Id_PrBLMateriale
					)
		
	-- Restituisce la quantità nel fattore richiesto
	return case when @QtaUM1 is null then null else @QtaUM1 / @FattoreToUM1 end

	-- declare @Id_xMOPRTR int = 1
	-- declare @Cd_Operatore varchar(20) = 'marco'

	--select
	--	Ordine = row_number() over(order by Id_PrBLMateriale, Tipo)
	--	, *
	--from (
	--	-- Dati dell'articolo
	--	select
	--		Tipo			= 0 -- Testa articolo
	--		, Id_PrBLMateriale= PRBLMateriale.Id_PrBLMateriale
	--		, Cd_Operatore	= null
	--		, Cd_AR			= AR.Cd_AR			
	--		, Descrizione	= AR.Descrizione	
	--		, Cd_ARLotto	= x.Cd_ARLotto	
	--		, QtaTrasferita	= sum(x.QtaUM1) / PRBLMateriale.FattoreToUM1
	--		, Consumo		= PRBLMateriale.Consumo 
	--		, Cd_ARMisura	= PRBLMateriale.Cd_ARMisura
	--		, FattoreToUM1	= PRBLMateriale.FattoreToUM1
	--		, Del			= cast(0 as bit)
	--	from (
	--		select
	--			Id_PrBLMateriale= xMOPRTRRig.Id_PrBLMateriale
	--			, Cd_ARLotto	= xMOPRTRRig.Cd_ARLotto
	--			, QtaUM1		= cast(xMOPRTRRig.Quantita * xMOPRTRRig.FattoreToUM1 as numeric(18, 8))
	--		from
	--			xMOPRTRRig
	--				inner join xMOPRTR on xMOPRTRRig.Id_xMOPRTR = xMOPRTR.Id_xMOPRTR
	--		where
	--				xMOPRTR.Id_PrBLAttivita = @Id_PrBLAttivita
	--			And Stato = 0
	--	) x
	--		inner join PRBLMateriale on x.Id_PrBLMateriale = PRBLMateriale.Id_PrBLMateriale
	--		inner join AR on PRBLMateriale.Cd_AR = AR.Cd_AR
	--	group by 
	--		PRBLMateriale.Id_PrBLMateriale	
	--		, AR.Cd_AR			
	--		, AR.Descrizione	
	--		, x.Cd_ARLotto	
	--		, PRBLMateriale.Consumo 
	--		, PRBLMateriale.Cd_ARMisura
	--		, PRBLMateriale.FattoreToUM1
	--	union
	--		-- Letture
	--	select	
	--		Tipo			= 1 -- Letture articolo
	--		, Id_PrBLMateriale= PRBLMateriale.Id_PrBLMateriale
	--		, Cd_Operatore	= xMOPRTRRig.Cd_Operatore
	--		, Cd_AR			= null
	--		, Descrizione	= null
	--		, Cd_ARLotto	= xMOPRTRRig.Cd_ARLotto	
	--		, QtaTrasferita	= cast(sum(xMOPRTRRig.Quantita * xMOPRTRRig.FattoreToUM1) / PRBLMateriale.FattoreToUM1 as numeric(18,8))
	--		, Consumo		= null 
	--		, Cd_ARMisura	= PRBLMateriale.Cd_ARMisura
	--		, FattoreToUM1	= PRBLMateriale.FattoreToUM1
	--		, Del			= cast(case when xMOPRTRRig.Cd_Operatore = @Cd_Operatore then 1 else 0 end as bit)
	--	from
	--		xMOPRTRRig
	--			inner join xMOPRTR on xMOPRTRRig.Id_xMOPRTR = xMOPRTR.Id_xMOPRTR
	--			inner join PRBLMateriale on xMOPRTRRig.Id_PrBLMateriale = PRBLMateriale.Id_PrBLMateriale
	--	where
	--			xMOPRTR.Id_PrBLAttivita = @Id_PrBLAttivita
	--		And Stato = 0
	--	group by 
	--		PRBLMateriale.Id_PrBLMateriale	
	--		, xMOPRTRRig.Cd_Operatore
	--		, xMOPRTRRig.Cd_ARLotto	
	--		, PRBLMateriale.Consumo 
	--		, PRBLMateriale.Cd_ARMisura
	--		, PRBLMateriale.FattoreToUM1
	--) 
	--	xMORLLetture
end
go

create function xmofn_xMOPRBLMateriali (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_PRBLAttivita	int
	, @QtaUsrUM1		numeric(18, 8)
) returns @out table (
	Ordinamento			int
	-- Bolla
	, Id_PrBL			int
	, Bolla				varchar(15)
	, DataObiettivo		smalldatetime
	, Id_PrBLAttivita	int
	-- Materiale
	, Id_PrBLMateriale	int
	, Cd_AR				varchar(20) 
	, Descrizione		varchar(80)
	, Cd_ARLotto		varchar(20)
	, Cd_MG_P			char(5)
	, Cd_MGUbicazione_P	varchar(20)
	, Cd_xMOLinea		varchar(20)
	, Cd_MG_A			char(5)
	, Cd_MGUbicazione_A	varchar(20)
	, Cd_ARMisura		char(2)
	, FattoreToUM1		numeric(18,8)
	-- La giacenza è riconvertita nell'UM del materiale
	, Giacenza			numeric(18,8)
	, Consumo			numeric(18,8)
	, ConsumoUsr		numeric(18,8)
	, QtaTrasferita		numeric(18,8)
	, QtaDaTrasferire	numeric(18,8)
	, Mancante			bit
	, NotePrBLMateriale	varchar(max)
)
/*ENCRYPTED*/
as begin
	
	declare @divisore numeric(18, 8)
	set @divisore = @QtaUsrUM1 / (select Quantita * FattoreToUM1 from PROLAttivita where Id_PrOLAttivita = (select Id_PrOLAttivita from PRBLAttivita Where Id_PrBLAttivita = @Id_PRBLAttivita))

	insert into @out
	select 
		Ordinamento			= row_number() over(order by PRBLMateriale.Id_PrBLAttivita, PRBLMateriale.Sequenza)
		-- Bolla
		, Id_PrBL			= PRBL.Id_PrBL
		, Bolla				= ltrim(rtrim(str(PRBL.Numero))) + '/' + ltrim(rtrim(str(PRBL.Anno)))
		, DataObiettivo		= PRBL.DataObiettivo		
		, Id_PrBLAttivita	= PRBLAttivita.Id_PrBLAttivita
		-- , Cd_MG_M			= PRRisorsa.Cd_MG_M			-- Magazzino di prelievo materiali REM DA VERIFICARE
		-- Materiale
		, Id_PrBLMateriale	= PrBLMateriale.Id_PrBLMateriale -- Necessario per creare il trasferimento
		, Cd_AR				= PRBLMateriale.Cd_AR
		, Descrizione		= AR.Descrizione
		, Cd_ARLotto		= PRBLMateriale.Cd_ARLotto
		, Cd_MG_P			= PRBLMateriale.Cd_MG		-- Magazzino di calcolo dei prelievi
		, Cd_MGUbicazione_P	= PRBLMateriale.Cd_MGUbicazione
		, Cd_xMOLinea		= xMOLinea.Cd_xMOLinea
		, Cd_MG_A			= xMOLinea.Cd_MG
		, Cd_MGUbicazione_A	= xMOLinea.Cd_MGUbicazione
		, Cd_ARMisura		= PRBLMateriale.Cd_ARMisura
		, FattoreToUM1		= PRBLMateriale.FattoreToUM1
		, Giacenza			= 0
		, Consumo			= PRBLMateriale.Consumo
		, ConsumoUsr		= cast(PRBLMateriale.Consumo * @divisore as numeric(18, 8))
		, QtaTrasferita		= cast(isnull((select dbo.xmofn_xMOPRTR_QtaTrasferita(PRBLMateriale.Id_PrBLAttivita, PRBLMateriale.Id_PrBLMateriale, PRBLMateriale.FattoreToUM1)), 0) as numeric(18,8))
		-- La quantità trasferita è già nel fattore del materiale NULLO se non c'è nulla da trasferire
		, QtaDaTrasferire	= (select dbo.xmofn_xMOPRTR_QtaDaTrasferire(PRBLMateriale.Id_PrBLAttivita, PRBLMateriale.Id_PrBLMateriale, PRBLMateriale.FattoreToUM1))
		, Mancante			= cast(
								case when 
										exists(select * from xMOPRTR inner join xMOPRTRRig on xMOPRTR.Id_xMOPRTR = xMOPRTRRig.Id_xMOPRTR where xMOPRTR.Id_PrBLAttivita = PRBLMateriale.Id_PrBLAttivita And xMOPRTR.Stato = 0 And xMOPRTRRig.Id_PrBLMateriale = PRBLMateriale.Id_PrBLMateriale And xMOPRTRRig.Mancante = 1) 
										Or 
										exists(select * from PRTRMateriale m inner join PRTRAttivita a on m.Id_PRTRAttivita = a.Id_PrTRAttivita where a.Id_PrBLAttivita = PRBLAttivita.Id_PrBLAttivita And m.xId_PrBLMateriale = PRBLMateriale.Id_PrBLMateriale And m.xMancante = 1) 
									then 1 else 0 end 
								as bit)
		, NotePrBLMateriale	= PRBLMateriale.NotePrBLMateriale
	from 
		PRBLEx PRBL
			inner join PRRisorsa						on PRBL.Cd_PrRisorsa = PRRisorsa.Cd_PrRisorsa
			inner join xMOLinea							on xMOLinea.Cd_xMOLinea = PRRisorsa.xCd_xMOLinea
			inner join PrBLAttivitaEx	PrBLAttivita	on PRBL.Id_PrBL = PRBLAttivita.Id_PrBL
			inner join PrBLMaterialeEx	PrBLMateriale	on PRBLMateriale.Id_PrBLAttivita = PrBLAttivita.Id_PrBLAttivita
			inner join AR								on PRBLMateriale.Cd_AR = AR.Cd_AR
	where
			PrBLAttivita.Id_PrBLAttivita = @Id_PRBLAttivita
		And PrBLMateriale.Tipo = 2		-- Materie prime

	declare @Id_PrBLMateriale	int
	declare @Cd_Ar				varchar(20)
	declare @FattoreToUM1		numeric(18,8)
	declare @Cd_MG				char(5)
	declare @Cd_MGEsercizio		char(4) = dbo.afn_CGEsercizio(getdate())

	declare c_ar cursor for
	select Id_PrBLMateriale, Cd_Ar, FattoreToUM1, Cd_MG_P
	from @out

	open c_ar
	fetch next from c_ar into @Id_PrBLMateriale, @Cd_Ar, @FattoreToUM1, @Cd_MG

	while (@@fetch_status = 0) 
	begin

		update @out set
			Giacenza = cast(isnull((select Quantita from dbo.MGGiac(@Cd_MGEsercizio) mgg where Cd_MG = @Cd_MG And Cd_AR = @Cd_Ar), 0) * @FattoreToUM1 as numeric(18,8))
		where
			Id_PrBLMateriale = @Id_PrBLMateriale

		fetch next from c_ar into @Id_PrBLMateriale, @Cd_Ar, @FattoreToUM1, @Cd_MG

	end /*while*/

	close c_ar
	deallocate c_ar

	return
end
go

create function xmofn_xMOPRMPLinea
(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Cd_xMOLinea varchar(20)
) returns @out table (
	Cd_AR					varchar(20)
	, Descrizione			varchar(80)
	, Quantita				numeric(18,8)
	, Cd_ARMisura			char(2)
	, Cd_ARLotto			varchar(20)
	, Cd_DoSottoCommessa	varchar(20)
	, BL					bit 
	, Cd_MG_P				char(5)
	, Cd_MGUbicazione_P		varchar(20)
	, Cd_MG_A				char(5)
)
/*ENCRYPTED*/
as begin

	set @Cd_xMOLinea = case when isnull(@Cd_xMOLinea, '') = '' then null else @Cd_xMOLinea end

	declare @Cd_MGEsercizio		char(4) = dbo.afn_CGEsercizio(getdate())

	insert into @out
	select
		Cd_AR					= giac.Cd_AR
		, Descrizione			= AR.Descrizione
		, Quantita				= giac.Quantita
		, Cd_ARMisura			= AR.Cd_ARMisura
		, Cd_ARLotto			= giac.Cd_ARLotto
		, Cd_DoSottoCommessa	= null --giac.Cd_DoSottoCommessa
		-- Mostra le possibili bolle che deve utilizzare il materiali s
		, BL					= cast(case when exists(
										select m.* 
										from PrBLMaterialeEx m 
										where 
												m.Cd_AR = giac.Cd_AR 
											And m.Id_PrBL In (
												select PrBL.Id_PrBL 
												from PrBLEx PrBL
													inner join PRRisorsa on PrBL.Cd_PrRisorsa = PRRisorsa.Cd_PrRisorsa
													inner join xMOLinea	 on PRRisorsa.xCd_xMOLinea = xMOLinea	.Cd_xMOLinea
												where 
														PrBL.Prodotto = 0 
													And PrBL.InCorso = 0 
													And PrBL.Trasferito = 0
												)
										) then 1 else 0 end as bit)
		-- I magazzini di partenza sono quelli della linea di produzione
		, Cd_MG_P				= xMOLinea.Cd_MG
		, Cd_MGUbicazione_P		= xMOLinea.Cd_MGUbicazione
		, Cd_MG_A				= (select top 1 PrdCd_MG_C from xMOImpostazioni)
	from
		dbo.MGGiacEx(@Cd_MGEsercizio)	giac
			inner join AR				on giac.Cd_AR = AR.Cd_AR
			inner join xMOLinea			on giac.Cd_MG = xMOLinea.Cd_MG And isnull(giac.Cd_MGUbicazione, '') = isnull(xMOLinea.Cd_MGUbicazione, '')
	where
			(@Cd_xMOLinea is null Or xMOLinea.Cd_xMOLinea = @Cd_xMOLinea)
		And giac.Quantita > 0

	return 

end
go

create function xmofn_xMOPRBLMateriali_4BL
(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_AR			varchar(20)
) returns table 
/*ENCRYPTED*/
as return (

		-- Bolle di arrivo
		select 
	         Ordinamento                = row_number() over(order by PrBL.Data, PRBLAttivita.Id_PrBLAttivita)
             -- Bolla
             , Id_PrBL                  = PRBL.Id_PrBL
             , Bolla                    = ltrim(rtrim(str(PRBL.Numero))) + '/' + ltrim(rtrim(str(PRBL.Anno)))
             , DataObiettivo            = PRBL.DataObiettivo       
             , Id_PrBLAttivita			= PRBLAttivita.Id_PrBLAttivita
			 , Id_PrBLMateriale			= PRBLMateriale.Id_PrBLMateriale
			 , Cd_xMOLinea				= xMOLinea.Cd_xMOLinea
			 , Cd_PrRisorsa				= PRBL.Cd_PrRisorsa
			 , Descrizione				= PrBLAttivita.Descrizione
			 , Quantita					= PRBLMateriale.Consumo
			 , Cd_ARMisura				= PRBLMateriale.Cd_ARMisura
       from 
             PRBLEx PRBL
                    inner join PRRisorsa                     on PRBL.Cd_PrRisorsa = PRRisorsa.Cd_PrRisorsa
                    inner join xMOLinea                      on xMOLinea.Cd_xMOLinea = PRRisorsa.xCd_xMOLinea
                    inner join PrBLAttivitaEx  PrBLAttivita  on PRBL.Id_PrBL = PRBLAttivita.Id_PrBL
                    inner join PrBLMaterialeEx PrBLMateriale on PRBLMateriale.Id_PrBLAttivita = PrBLAttivita.Id_PrBLAttivita
       where
					PRRisorsa.xCd_xMOLinea is not null
				And PRBL.Esecutivo = 1
				And PRBL.Prodotto = 0
				-- Da gestire
				-- And PROL.Esecutivo = 1
				-- And PROL.Sospeso = 0
				And PrBLMateriale.Tipo = 2        -- Materie prime
                And PrBLMateriale.Cd_AR = @Cd_AR  -- Articolo
				And PRBLMateriale.Consumo > cast((select dbo.xmofn_xMOPRTR_QtaTrasferita(PRBLMateriale.Id_PrBLAttivita, PRBLMateriale.Id_PrBLMateriale, PRBLMateriale.FattoreToUM1)) as numeric(18,8))
											

)
go

-- -------------------------------------------------------------
--		#3.5		aggiunge le viste 
-- -------------------------------------------------------------

create view xmovs_DOTes
as (
	select 
		Id_DOTes						= DOTes.Id_DOTes
		, Cd_DO							= DOTes.Cd_DO
		, NumeroDoc						= DOTes.NumeroDoc
		, DataDoc						= DOTes.DataDoc
		, Cd_MGEsercizio				= DOTes.Cd_MGEsercizio
		, DataConsegna					= DOTes.DataConsegna
		, Cd_DOSottoCommessa			= DOTes.Cd_DOSottoCommessa
		, DOSottoCommessa_Descrizione	= sc.Descrizione
		, NumeroDocRif					= DOTes.NumeroDocRif
		, DataDocRif					= DOTes.DataDocRif
		-- CF/CFDEST: i campi predefiniti sono quelli della destinazione poi del CF
		, Cd_CF							= CF.Cd_CF
		, CF_Descrizione				= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Descrizione	else CF.Descrizione	end 
		, Indirizzo						= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Indirizzo		else CF.Indirizzo	end
		, Localita						= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Localita		else CF.Localita	end
		, Cap							= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Cap			else CF.Cap	end
		, Cd_Provincia					= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Cd_Provincia	else CF.Cd_Provincia	end
		, Cd_Nazione					= case when isnull(DOTes.Cd_CFDest, '') <> '' then CFDest.Cd_Nazione	else CF.Cd_Nazione	end
		, PrelevatoDa					= (select top 1 rl.Cd_DO + ' MOOVI [' + ltrim(rtrim(str(rl.Id_xMORL))) + '] del ' + convert(varchar(10), rl.DataDoc, 105) + ' (' + rl.Cd_Operatore + ')'  from xMORL rl inner join xMORLPrelievo rlp on rl.Id_xMORL = rlp.Id_xMORL where rlp.Id_DOTes = DOTes.Id_DOTes And rl.Stato = 0)
		, Cd_PG							= DOTes.Cd_PG
		, Ds_PG							= PG.Descrizione
		, NotePiede						= DOTes.NotePiede
	from 
		DOTes 
			inner join	CFEx				CF		on DOTes.Cd_CF = CF.Cd_CF
			left join	CFDestEx			CFDest	on DOTes.Cd_CF = CFDest.Cd_CF And DOTes.Cd_CFDest = CFDest.Cd_CFDest
			left join	PG							on DOTes.Cd_PG = PG.Cd_PG
			left join	DOSottoCommessa		sc		on DOTes.Cd_DOSottoCommessa = sc.Cd_DOSottoCommessa
)
go

create view xmovs_DORig 
as (
	select 
		Id_DOTes			= DORig.Id_DOTes
		, Id_DORig			= DORig.Id_DORig
		, Cd_AR				= DORig.Cd_AR
		, Descrizione		= DORig.Descrizione
		, Cd_ARMisura		= upper(DORig.Cd_ARMisura)
		, FattoreToUM1		= DORig.FattoreToUM1
		, Qta				= DORig.Qta
		, QtaEvadibile		= DORig.QtaEvadibile
		, Cd_ARLotto		= DORig.Cd_ARLotto
		, Matricole			= DORig.Matricole
	from 
		DORig 
			-- inner join AR on DORig.Cd_AR = AR.Cd_AR
	where
			isnull(Cd_AR, '') <> '' 
		And QtaEvadibile > 0
)
go

create view xmovs_xMORL
as
(
	select 
		Id_xMORL				= xMORL.Id_xMORL
		, Cd_DO					= xMORL.Cd_DO
		, Terminale				= xMORL.Terminale
		, Cd_Operatore			= xMORL.Cd_Operatore
		, Stato					= xMORL.Stato
		, Id_DOTes				= xMORL.Id_DOTes
		, Cd_CF					= xMORL.Cd_CF
		, CF_Descrizione		= CF.Descrizione
		, Cd_CFDest				= xMORL.Cd_CFDest
		, CFDest_Descrizione	= CFDest.Descrizione
		, DataDoc				= xMORL.DataDoc
		, Cd_DOSottoCommessa	= xMORL.Cd_DOSottoCommessa
		, Cd_xMOLinea			= xMORL.Cd_xMOLinea
		, NumeroDocRif			= xMORL.NumeroDocRif			
		, DataDocRif			= xMORL.DataDocRif			
		, NotePiede				= xMORL.NotePiede				
		, Cd_MG_P				= xMORL.Cd_MG_P				
		, MG_P_Descrizione		= mgp.Descrizione
		, Cd_MG_A				= xMORL.Cd_MG_A				
		, MG_A_Descrizione		= mga.Descrizione
		, Targa					= xMORL.Targa			
		, Cd_DOCaricatore		= xMORL.Cd_DOCaricatore		
		, PesoExtraMks			= xMORL.PesoExtraMks
		, VolumeExtraMks		= xMORL.VolumeExtraMks
		, CountPrelievi			= (select COUNT(*) from xMORLPrelievo Where Id_xMORL = xMORL.Id_xMORL)
	from 
		xMORL
			inner join CF			on xMORL.Cd_CF = CF.Cd_CF
			left join CFDest		on xMORL.Cd_CF = CFDest.Cd_CF And xMORL.Cd_CFDest = CFDest.Cd_CFDest
			left join MG		mgp	on xMORL.Cd_MG_P = mgp.Cd_MG
			left join MG		mga	on xMORL.Cd_MG_A = mgp.Cd_MG
)
go

create view xmovs_xMORLRig
as
(
	select
		Ordinamento			= ROW_NUMBER() over(order by xMORLRig.Id_xMORL, xMORLRig.Id_xMORLRig desc)
		, Terminale			= xMORLRig.Terminale	
		, Cd_Operatore		= xMORLRig.Cd_Operatore
		, Id_xMORLRig		= xMORLRig.Id_xMORLRig	
		, Id_xMORL			= xMORLRig.Id_xMORL	
		, Cd_AR				= xMORLRig.Cd_AR	
		, Descrizione		= AR.Descrizione
		, Cd_MG_P			= xMORLRig.Cd_MG_P	
		, Cd_MGUbicazione_P	= xMORLRig.Cd_MGUbicazione_P	
		, Cd_MG_A			= xMORLRig.Cd_MG_A	
		, Cd_MGUbicazione_A	= xMORLRig.Cd_MGUbicazione_A	
		, Cd_ARLotto		= xMORLRig.Cd_ARLotto	
		, Matricola			= xMORLRig.Matricola	
		, Cd_ARMisura		= upper(xMORLRig.Cd_ARMisura)
		, FattoreToUM1		= xMORLRig.FattoreToUM1	
		, Quantita			= xMORLRig.Quantita	
		, DataOra			= xMORLRig.DataOra	
		, Barcode			= xMORLRig.Barcode	
	from
		xMORLRig
			inner join AR		on AR.Cd_AR = xMORLRig.Cd_AR
			
)
go

create view xmovs_DO
as(
	select
		Ordinamento			= ROW_NUMBER() over (order by Cd_DO)
		, Cd_DO				= DO.Cd_DO
		, DO_Descrizione	= DO.Descrizione
		, TipoDocumento		= DO.TipoDocumento
		, CF				= DO.CliFor
		, Ciclo				= Case When DO.CliFor = 'C'												Then 'ca' 
									When DO.CliFor = 'F' And DO.TipoDocumento = 'T'					Then 'tr'
									When DO.CliFor = 'F' And DO.TipoDocumento IN('L', 'R', 'V')		Then 'ad'
									Else																 'cp'
								End
		-- Causale di magazzino
		, Cd_MGCausale		= MGCausale.Cd_MGCausale
		, MGC_Descrizione	= MGCausale.Descrizione
		-- Magazzino di partenza
		, MagPFlag			= MGCausale.MagPFlag		-- Vero se il magazzino di partenza è attivo 
		, Cd_MG_P			= MGCausale.Cd_MG_P			-- Magazzino di partenza (se vuoto in moovi va specificato)
		, MGP_Descrizione	= mg_p.Descrizione
		, UIMagPFix			= MGCausale.UIMagPFix		-- Magazzino FISSO (se vero il magazzino non è modificabile)
		, MGP_UbicazioneObbligatoria = mg_p.MG_UbicazioneObbligatoria 
		-- Magazzino di arrivo
		, MagAFlag			= MGCausale.MagAFlag		-- Vero se il magazzino di arrivo è attivo
		, Cd_MG_A			= MGCausale.Cd_MG_A			-- Magazzino di arrivo (se vuoto in moovi va specificato)
		, MGA_Descrizione	= mg_a.Descrizione
		, UIMagAFix			= MGCausale.UIMagAFix		-- Magazzino FISSO (se vero il magazzino non è modificabile)
		, MGA_UbicazioneObbligatoria = mg_a.MG_UbicazioneObbligatoria 
		-- Gestione del lotto
		, ARLottoAuto		= DO.ARLottoAuto			-- Se 0 non è possibile creare il lotto; > 0 
		-- Matricola abilitata
		, MtrEnabled		= DO.MtrEnabled
		-- Numero Moduli definiti per il documento
		, Moduli			= (Select COUNT(*) from DOReport inner join ReportDocAll on DOReport.UD_ReportDoc = ReportDocAll.Ud_ReportDoc where DOReport.Cd_DO = DO.Cd_DO)
		-- , xMOAttivo		= DO.xMOAttivo
		, xMOCd_CF			= DO.xMOCd_CF
		, xMOCd_CFDest		= DO.xMOCd_CFDest
		, xMOPrelievo		= DO.xMOPrelievo			
		, xMOPrelievoObb	= DO.xMOPrelievoObb
		, xMOFuoriLista		= DO.xMOFuoriLista		
		, xMOUmDef			= DO.xMOUmDef
		, xMOLinea			= DO.xMOLinea			
		, xMOLotto			= DO.xMOLotto			
		, xMOUbicazione		= DO.xMOUbicazione			
		, xMOControlli		= DO.xMOControlli		
		, xMODatiPiede		= DO.xMODatiPiede		
		, xMOQuantitaDef	= DO.xMOQuantitaDef
		, xMOTarga			= DO.xMOTarga
		, xMOBarcode		= DO.xMOBarcode		
		, xMOTerminali		= DO.xMOTerminali
		, xCd_xMOProgramma	= DO.xCd_xMOProgramma
		, xMOStoccaggio		= DO.xMOStoccaggio
	from
		DO
			inner join	MGCausale			on DO.Cd_MGCausale = MGCausale.Cd_MGCausale
			left join	MG			mg_p	on MGCausale.Cd_MG_P = mg_p.Cd_MG
			left join	MG			mg_a	on MGCausale.Cd_MG_A = mg_a.Cd_MG
	where
		xMOAttivo = 1
)
go

create view xmovs_CF 
as (
	select 
		Cd_CF
		, Descrizione
		, Indirizzo
		, Localita
		, Cap
		, Cd_Provincia
		, Cd_Nazione
		-- , Telefono		### Implementare la gestione dei numeri di telefono da CFContatto
	from 
		CFEx CF
	where
		Obsoleto = 0	
)
go

create view xmovs_CFDest
as (
	select 
		Cd_CFDest
		, d.Descrizione
		, Indirizzo
		, Localita
		, Cap
		, Cd_Provincia
		, Cd_Nazione
		, Agente = d.Cd_Agente + ' - ' + ag.Descrizione
		, Telefono
	from 
		CFDestEx	d 
			left join Agente ag on d.Cd_Agente = ag.Cd_Agente
	where
		Obsoleto = 0	
)
go

-- Elenco di tutte le UM 
create view xmovs_ARMisura
as(
	Select
		Ordine			= ROW_NUMBER() over(order by xMODefault desc, Cd_ARMisura)
		, Cd_ARMisura	= upper(Cd_ARMisura)
	From 
		ARMisura
)
go

create view xmovs_xMOTRRig_P
as
(
	select
		Ordinamento			= ROW_NUMBER() over(order by xMOTRRig_P.Id_xMOTR, xMOTRRig_P.Id_xMOTRRig_P desc)
		, Terminale			= xMOTRRig_P.Terminale	
		, Cd_Operatore		= xMOTRRig_P.Cd_Operatore
		, Id_xMOTRRig_P		= xMOTRRig_P.Id_xMOTRRig_P	
		, Id_xMOTR			= xMOTRRig_P.Id_xMOTR	
		, Cd_AR				= xMOTRRig_P.Cd_AR	
		, Descrizione		= AR.Descrizione
		, Cd_MG_P			= xMOTRRig_P.Cd_MG_P	
		, Cd_MGUbicazione_P	= xMOTRRig_P.Cd_MGUbicazione_P	
		, Cd_ARLotto		= xMOTRRig_P.Cd_ARLotto		
		, Cd_ARMisura		= upper(xMOTRRig_P.Cd_ARMisura)
		, FattoreToUM1		= xMOTRRig_P.FattoreToUM1	
		, Quantita			= xMOTRRig_P.Quantita	
		, DataOra			= xMOTRRig_P.DataOra		
	from
		xMOTRRig_P
			inner join AR		on AR.Cd_AR = xMOTRRig_P.Cd_AR
			
)
go

create view xmovs_xMOTRRig_A
as
(
	select
		Ordinamento			= ROW_NUMBER() over(order by a.Id_xMOTR, a.Id_xMOTRRig_A desc)
		, Terminale			= a.Terminale	
		, Cd_Operatore		= a.Cd_Operatore
		, Id_xMOTRRig_A		= a.Id_xMOTRRig_A	
		, Id_xMOTR			= a.Id_xMOTR	
		, Cd_AR				= p.Cd_AR	
		, Descrizione		= AR.Descrizione
		, Cd_MG_A			= a.Cd_MG_A	
		, Cd_MGUbicazione_A	= a.Cd_MGUbicazione_A	
		, Cd_ARMisura		= upper(a.Cd_ARMisura)
		, FattoreToUM1		= a.FattoreToUM1	
		, Quantita			= a.Quantita	
		, DataOra			= a.DataOra		
	from
		xMOTRRig_A	a
			inner join xMOTRRig_P  p	on p.Id_xMOTRRig_P = a.Id_xMOTRRig_P
			inner join AR				on AR.Cd_AR = p.Cd_AR
			
)
go

create view xmovs_xMORLRig_ExtFld
as
(
	select 
		Id_xMORL
		, Id_xMORLRig
		, Nome		= IsNull(o.value('@nome', 'varchar(max)'), '') 
		, Valore	= IsNull(o.value('@valore', 'varchar(max)'), '') 
	from
		xMORLRig
			Cross Apply ExtFld.nodes('rows/row') AS x(o) 	
)
go



-- -------------------------------------------------------------
--	#3.5.1		aggiunge gli indici alle viste
-- -------------------------------------------------------------

-- -------------------------------------------------------------
--	#3.6		aggiunge i trigger
-- -------------------------------------------------------------
create trigger crea_lotto on xMOMatricola
after insert
as 
	declare @Cd_ARLotto		varchar(20) 
	declare @Cd_AR			varchar(20) 
	declare @DataScadenza	smalldatetime

	select 
		@Cd_AR				= Cd_AR
		, @Cd_ARLotto		= Cd_ARLotto 
		, @DataScadenza		= DataScadenza
	from 
		inserted
	 
	if not exists (select * from ARLotto where Cd_ARLotto = @Cd_ARLotto and Cd_AR = @Cd_AR)
		insert into ARLotto(Cd_ARLotto, Cd_AR, Descrizione, DataScadenza)
		values (@Cd_ARLotto, @Cd_AR, 'Lotto ' + @Cd_ARLotto, isnull(@DataScadenza ,getdate()))

go


create trigger xMO_DORig_xMOMatricola_Disponibile on DORig
after insert
as 
	if exists(select * from inserted where Matricole is not null) begin
							
		declare @xMOMatDisp smallint

		-- Recupero il tipo di azione su disponibilità della matricola dal documento SOLO se sono presenti Matricole in inserted
		set @xMOMatDisp = isnull((
								select xMOMatDisp 
								from DO 
								where 
									Cd_DO = (Select top 1 DOTes.CD_Do from DOTes inner join inserted on DOTes.Id_DoTes = inserted.Id_DoTes)
								), 0)

		-- Verifico che sia presenta l'azione (1 = Disponibile; 2 = Non Disponibile)
		if (@xMOMatDisp > 0) begin
			declare @Disattiva bit
			-- Seleziona lo stato finale della matricola
			set @Disattiva = case when @xMOMatDisp = 1 then 0 else 1 end 
			-- Aggiorno tutte le matricole presenti nella riga inserted come richiesto dalla tipologia del documento
			update xMOMatricola set
				Disattiva = @Disattiva
			where 
				Cd_xMOMatricola in (
					Select
						IsNull(m.x.value('@matricola', 'varchar(80)'), '') As Matricola
					From 
						inserted 
							Cross Apply Matricole.nodes('rows/row') AS m(x) 
					)
				And Disattiva <> @Disattiva;
		end 
	end
go

-- -------------------------------------------------------------
--	#3.7		aggiunge le stored procedure 
-- -------------------------------------------------------------

--procedura per il login
create procedure xmosp_Login (
		@Terminale		varchar(39),
		@Cd_Operatore	varchar(20),
		@Password		varchar(80)
)
/*ENCRYPTED*/
as begin
		
		declare @r						int				-- risultato della sp (@r = 1: il log-in è andato a buon fine)
		declare @ImpLogInTerminale		bit				-- Impostazioni Globali: il terminale va validato
		declare @ImpMovTraAbilita		bit				-- Impostazioni Globali: Attiva/Disattiva la gestione dei movimenti interni
		declare @ImpMovTraDescrizione	varchar(30)		-- Descrizione dei movimenti interni
		declare @ImpMovTraUbicazione	bit				-- Impostazioni Globali: Attiva/Disattiva la gestione dell''ubicazione per i movimenti interni
		declare @ImpMovTraLotto			bit				-- Attiva/Disattiva la gestione del lotto per i movimenti interni
		declare @ImpMovTraCommessa		bit				-- Attiva/Disattiva la gestione del lotto per i movimenti interni
		declare @ImpMovInvAbilita		bit				-- Impostazioni Globali: Attiva/Disattiva la gestione dei movimenti interni
		declare @ImpMovInvDescrizione	varchar(30)		-- Descrizione dei movimenti interni
		declare @ImpMovInvUbicazione	bit				-- Impostazioni Globali: Attiva/Disattiva la gestione dell''ubicazione per i movimenti interni
		declare @ImpMovInvLotto			bit				-- Attiva/Disattiva la gestione del lotto per i movimenti interni
		declare @ImpMovInvCommessa		bit				-- Attiva/Disattiva la gestione del lotto per i movimenti interni
		declare @MovTraAbilita			bit				-- Attiva/Disattiva la gestione dei trasferimenti interni
		declare @MovInvAbilita			bit				-- Attiva/Disattiva la gestione dell'inventario
		declare @SpeAbilita				bit				-- Attiva/Disattiva la gestione delle spedizioni
		declare @ListenerIP				varchar(39) 	-- Indirizzo Ip del Listener
		declare @ListenerPort			int				-- Indirizzo socket del Listener
		declare @ListenerReplayPort		int				-- Indirizzo socket di risposta del Listener al terminale
		declare @SetFocus				smallint		-- Tipo di set focus del terminale
		declare @m						varchar(max)	-- Messaggio di errore

		declare @Id_Operatore			int				-- Contiene l'identificativo univoco dell'operatore
		declare @ListenerAttivi			int				-- Contiene il count dei listener attivi, login non valido se = 0

		Begin try

			-- Recupero le impostazioni globali
			select top 1
				@ImpLogInTerminale			= LogInTerminale
				, @ImpMovTraAbilita			= MovTraAbilita
				, @ImpMovTraDescrizione		= MovTraDescrizione
				, @ImpMovTraUbicazione		= MovTraUbicazione
				, @ImpMovTraLotto			= MovTraLotto
				, @ImpMovTraCommessa		= MovTraCommessa
				, @ImpMovInvAbilita			= MovInvAbilita
				, @ImpMovInvDescrizione		= MovInvDescrizione
				, @ImpMovInvUbicazione		= MovInvUbicazione
				, @ImpMovInvLotto			= MovInvLotto
				, @ImpMovInvCommessa		= MovInvCommessa
				, @SpeAbilita				= SpeAbilita
				-- ### Da creare i default per listener IP, ListenPort, ReplayPort
			from
				xMOImpostazioni

			-- Esegue la verifica al login ANCHE del terminale se è stato richiesto (LogInTerminale dalle impostazioni di MOOVI)
			if (@ImpLogInTerminale = 1) begin

				-- Verifica che il terminale sia attivo per moovi
				if not exists(select * from xMOTerminale where Terminale = @Terminale) begin
					set @r = -10; set @m = 'Il Terminale ' + @Terminale + ' non è codificato nell''anagrafica di MOOVI!!'; goto exitsp;
				end else begin
					if not exists(select * from xMOTerminale where Terminale = @Terminale And Attivo = 1) begin
						set @r = -15; set @m = 'Il Terminale ' + @Terminale + ' è Disattivo in MOOVI!!'; goto exitsp;
					end
				end

				-- Seleziona i parametri di default dal terminale
				select 
					@MovTraAbilita			= @ImpMovTraAbilita
					, @MovInvAbilita		= @ImpMovInvAbilita
					, @ListenerIP			= l.IP
					, @ListenerPort			= l.ListenPort
					, @ListenerReplayPort	= l.ReplayPort
					, @SetFocus				= t.SetFocus
				from
					xMOTerminale t
						left join xMOListener l on t.Cd_xMOListener = l.Cd_xMOListener
				where
					t.Terminale = @Terminale

			end else begin

				-- Imposta i parametri dalle impostazioni globali perché il terminale non va validato
				set @MovTraAbilita			= @ImpMovTraAbilita
				set @MovInvAbilita			= @ImpMovInvAbilita
				-- ## Da fare
				-- set @ListenerIP			= l.IP
				-- set @ListenerPort		= l.ListenPort
				-- set @ListenerReplayPort	= l.ReplayPort
				-- set @SetFocus			= 1
			
			end

			-- ........................................................
			-- TESTA LE VARIABILI DOPO LA LORO SELEZIONE DAI DATI
			-- ........................................................
			-- Verifica che l'operatore sia attivo per moovi
			if not exists(select * from Operatore where xMOAttivo = 1 And Cd_Operatore = @Cd_Operatore) begin
				set @r = -20; set @m = 'Operatore ' + isnull(@Cd_Operatore, '') + ' non attivo per MOOVI!!'; goto exitsp;
			end

			-- Verifica che l'operatore e la password siano coerenti
			set @Id_Operatore = (select Id_Operatore from Operatore where Cd_Operatore = @Cd_Operatore And [Password] = @Password)
			if isnull(@Id_Operatore, 0) = 0 begin
				set @r = -30; set @m = 'Password inserita errata!!'; goto exitsp;
			end

			-- Verifica che l'operatore e la password siano coerenti
			set @ListenerAttivi = (select count(*) from xMOListener where Attivo = 1)
			if isnull(@ListenerAttivi, 0) = 0 begin
				set @r = -40; set @m = 'Nessun listener attivo!!'; goto exitsp;
			end

			set @r = 1;

		End Try

		Begin catch 
			set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
		End Catch

		exitsp:
			-- restituisce il risultato dei controlli con una select
			select 
				Result					= @r
				, MovTraAbilita			= @MovTraAbilita			-- Sia nelle impostazioni globali che nei terminali
				, MovTraDescrizione		= @ImpMovTraDescrizione		-- Solo una impostazione globale
				, MovTraUbicazione		= @ImpMovTraUbicazione		-- Sia nelle impostazioni globali che nei terminali
				, MovTraLotto			= @ImpMovTraLotto			-- Solo una impostazione globale
				, MovTraCommessa		= @ImpMovTraCommessa		-- Solo una impostazione globale
				, MovInvAbilita			= @MovInvAbilita			-- Sia nelle impostazioni globali che nei terminali
				, MovInvDescrizione		= @ImpMovInvDescrizione		-- Solo una impostazione globale
				, MovInvUbicazione		= @ImpMovInvUbicazione		-- Sia nelle impostazioni globali che nei terminali
				, MovInvLotto			= @ImpMovInvLotto			-- Solo una impostazione globale
				, MovInvCommessa		= @ImpMovInvCommessa		-- Solo una impostazione globale
				, SpeAbilita				= @SpeAbilita
				, ListenerIP			= @ListenerIP
				, ListenerPort			= @ListenerPort
				, ListenerReplayPort	= @ListenerReplayPort
				, SetFocus				= @SetFocus
				, LicF_Id				= (select Value from ADB_System.aad.License where Name = 'LicF_Id')
				, MRP_Advanced			= cast(case when exists (select * from ADB_SYSTEM.aad.license where CONVERT(VARCHAR(max), name) = 'LicF_MRP_Advanced' And Value = 1) then 1 else 0 end as bit)
				, Messaggio				= isnull(@m, 'Log-in effettuato con successo')

				return @r
end
go

-- Documenti prelevabili da Id
create procedure xmosp_DOTes_Prel_ById(	
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)
	, @Id_DOTes		int
)
/*ENCRYPTED*/
as begin
	
	-- Recupera il cliente e il fornitore dall'Id
	declare @Cd_CF char(7)

	select @Cd_CF = Cd_CF from DOTes where Id_DOTes = @Id_DOTes

	-- Seleziona i doc prelevabile e li restituisce ordinati per l'id passato alla funzione
	select 
		*
	from 
		dbo.xmofn_DOTes_Prel(@Terminale, @Cd_Operatore, null, @Cd_CF, null, null) p
	order by
		case when Id_DOTes = @Id_DOTes then 0 else Id_DOTes end

end
go

create procedure xmosp_Sscc_Validate(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)		
	, @Id_xMORL			int
	, @Cd_xMOBC			char(10)
	, @Sscc				varchar(80)
	, @EseguiControlli	bit
	, @id_lettura		int				-- Codice indice client di verifica (opzionale)
	-- ### Aggiunge il campo della packinglist (@PackListRef)
)
/*ENCRYPTED*/
as begin

	-- ATTENZIONE 
	-- LA SP	restituisce  1	se è andato tutto OK
	--			restituisce  2	se necessita di APPROVAZIONE UTENTE (SI/NO)
	--			restituisce <0	se ERRORE

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		declare @Id_xMOMatricola	as int

		-- Controlla la matricola e restituisce i campi utili al completamento della lettura		
		if (isnull(@Sscc, '') = '') begin
			set @r = -10; set @m = 'Codice Sscc errato o mancante!!'; goto exitsp;
		end
	
		---- ATTENZIONE: SPOSTATO PIU IN BASSO!!!!
		----Verifico che il codice non sia inserito nelle letture di testa 
		--if exists(select * from xMORLRig Where Id_xMORL = @Id_xMORL And Matricola = @Sscc) begin
		--	set @r = -20; set @m = 'Il codice Sscc è già presente nelle letture del documento corrente!!'; goto exitsp;
		--end

		-- Variabili per il recupero dei dati della lettura
		declare @Cd_AR				varchar(20)
		declare @Cd_ARLotto			varchar(20)
		declare @DataScadenza		smalldatetime
		declare @Matricola			varchar(80)
		declare @Cd_ARMisura		char(2) 		
		declare @Quantita			numeric(18,8)
		declare @Cd_MG_P			char(5) 		
		declare @Cd_MGUbicazione_P	varchar(20) 	
		declare @Cd_MG_A			char(5) 		
		declare @Cd_MGUbicazione_A	varchar(20) 	

		-- I magazzini vanno presi dalla testa del doc che si sta creando xMORL
		select
			@Cd_MG_P	= Cd_MG_P 
			, @Cd_MG_A	= Cd_MG_A 
		from 
			xMORL
		where 
			Id_xMORL = @Id_xMORL
		
		-- Verifica che la matricola sia inserita in xMOMatricola
		select top 1 
			@Id_xMOMatricola	= Id_xMOMatricola 
			, @Matricola		= Cd_xMOMatricola
			, @Cd_AR			= Cd_AR
			, @Cd_ARLotto		= Cd_ARLotto
			, @DataScadenza		= DataScadenza
			, @Quantita			= 1		-- Fisso (1 matricola = 1 quantità)
			--, @Cd_ARMisura		= (select top 1 upper(MatCd_ARMisura) from xMOImpostazioni) RECUPERATA DA AR
		from 
			xMOMatricola 
		where 
			Cd_xMOMatricola = @Sscc
			-- Da importare o Importata come CPI 
			And (Stato = 0 Or Stato = 1)
		
		-- MATRICOLA NULLA... Verifica che la matricola sia inserita in un documento
		if (isnull(@Id_xMOMatricola, 0) = 0) begin
			select top 1 
				@Id_xMOMatricola	= null 
				, @Matricola		= DORigMatricola.Matricola 
				, @Cd_AR			= DORig.Cd_AR
				, @Cd_ARLotto		= DORig.Cd_ARLotto
				, @Quantita			= 1		-- Fisso (1 matricola = 1 quantità)
				, @Cd_ARMisura		= upper(DORig.Cd_ARMisura)
			from 
				DORigMatricola 
					inner join DORig On DORigMatricola.Id_DORig = DORig.Id_DORig
			where 
				Matricola = @Sscc
		end

		-- Recupera l'UM dell'articolo ..............
		-- Carica la configurazione del documento
		declare @TipoARMisura char(1)
		declare @xMOUmDef smallint
		declare @TipoDocumento char(1)
		select 
			@TipoARMisura	= TipoARMisura
			, @xMOUmDef		= xMOUmDef 
			, @TipoDocumento = TipoDocumento

		from dbo.xmofn_DO(@Terminale, @Cd_Operatore) where Cd_DO = (select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)
		
		-- Se il documento che si sta creando è di tipo carico prod allora verifico se configurata nella configurazione di moovi una UM specifica
		if (@TipoDocumento = 'V') begin
			set @Cd_ARMisura = (select MatCd_ARMisura from xMOImpostazioni)
		end 

		if(ISNULL(@Cd_ARMisura, '') = '') begin
			-- Unità di misura coerente con il tipo di documento da generare
			select top 1 @Cd_ARMisura = Cd_ARMisura from dbo.xmofn_ARARMisura(@Terminale, @Cd_Operatore, @Cd_AR, @TipoARMisura, @xMOUmDef)
		end
		-- ...........................................

		-- ATTENZIONE Aggiunto il 11/03 il controllo della presenza della matricola in altre letture non va eseguito in caso di giacenza per matricola
		-- Esempio: se attivo la giac. per matricola di un pallet in xMOMatGiac troverò 960 pz della stessa matricola
		if(select xMOAbilitaMatGiac from AR where Cd_AR = @Cd_AR) = 0 begin
			--Verifico che il codice non sia inserito nelle letture di testa
			if exists(select * from xMORLRig Where Id_xMORL = @Id_xMORL And Matricola = @Sscc) begin
				set @r = -20; set @m = 'Il codice Sscc è già presente nelle letture del documento corrente!!'; goto exitsp;
			end
		end

		-- MATRICOLA NULLA: ERRORE!!
		if (isnull(@Matricola, '') = '') begin
			set @r = -30; set @m = 'Il codice Sscc non ha restituito valori validi!!'; goto exitsp;
		end

		-- Recupera i dati mancanti
		declare @Barcode			xml
		set @Barcode = '<rows><row codice="' + @Cd_xMOBC + '" valore="' + @Sscc + '" /></rows>'

		-- Crea la lettura in xMORL
		declare @res as table (Result int, Id_xMoRLRig int, Messaggio varchar(max))
		
		insert into @res (Result, Id_xMoRLRig, Messaggio)
		exec @r = xmosp_xMORLRig_Save @Terminale
								, @Cd_Operatore
								, @Id_xMORL				
								, @Cd_AR				
								, @Cd_MG_P				
								, @Cd_MGUbicazione_P	
								, @Cd_MG_A				
								, @Cd_MGUbicazione_A	
								, @Cd_ARLotto		
								, @DataScadenza			
								, @Matricola			
								, @Cd_ARMisura	
								, null				-- @UMFatt recuperato dall UM della matricola
								, @Quantita				
								, @Barcode
								, null				-- @Cd_DOSottoCommessa nulla perché non ricercabile da Sscc
								, @EseguiControlli
								, null				-- @PackListRef nulla perché non ricercabile da Sscc
								, null				-- @Id_DORig
								, null				-- @ExtFld xml contenente i dati dei campi personalizzati
								, @m output

		-- imposta i messaggi uguali a quelli passati alla sp
		select 
			@r = Result
			, @id = Id_xMoRLRig
			, @m = Messaggio
		from 
			@res

	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:

		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMOMatricola	= @id, 
			Messaggio		= isnull(@m, 'Articolo: ' + @Cd_AR),
			id_lettura		= @id_lettura			-- Identificativo client

		return @r

end
go

create procedure xmosp_IDDR_Validate(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)		
	, @Id_xMORL			int
	, @Id_DoRig			varchar(80)
) 
/*ENCRYPTED*/
as begin
	declare @out table ([Key] varchar(50), [Value] varchar(max))
	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	
	-- Se l'id della riga non fa parte del prelievo errore
	declare @Prelievo smallint
	Set @Prelievo = (Select xMOPrelievo From DO where Cd_DO = (Select Cd_DO From xMORL Where Id_xMORL = @Id_xMORL))
	if @Prelievo > 0 And exists(select * from xMORLPrelievo where Id_xMORL = @Id_xMORL) begin
		if not exists(select * from xMORLPrelievo where Id_xMORL = @Id_xMORL And Id_DORig = @Id_DoRig) begin
			set @r = -100; set @m = 'L''Id letto [' + cast(@Id_DoRig as varchar) + '] non fa parte dei documenti prelevati !!'; goto exitsp;
		end
	end

	-- Se l'id della riga è già stato letto
	if exists(select * from xMORLRig where Id_xMORL = @Id_xMORL And Id_DORig = @Id_DoRig) begin
		set @r = -150; set @m = 'L''Id  [' + cast(@Id_DoRig as varchar) + '] è già stato letto !!'; goto exitsp;
	end

	-- Controlla se il documento è prelevabile
    if not exists(select * from DORig where Id_DORig = @Id_DoRig And Cd_DO in (select Cd_DO_Prelevabile from DODOPrel where Cd_DO = (select Cd_do from xmorl where Id_xMORL = @Id_xMORL))) begin
		set @r = -200; set @m = 'L''Id  [' + cast(@Id_DoRig as varchar) + '] non è valido perché non fa parte dei documenti prelevabili !!'; goto exitsp;
    end

    -- Controlla se il documento ha quantità evadibile
    if not exists(select * from DORig where Id_DORig = @Id_DoRig And QtaEvadibile > 0) begin
		set @r = -250; set @m = 'L''Id  [' + cast(@Id_DoRig as varchar) + '] non possiede quantità evadibile !!'; goto exitsp;
    end

	-- Controlla che il documento abbia lo stesso CF
    if not exists(select * from DORig where Id_DORig = @Id_DoRig And Cd_CF = (select Cd_CF from xmorl where Id_xMORL = @Id_xMORL)) begin
		set @r = -200; set @m = 'L''Id  [' + cast(@Id_DoRig as varchar) + '] non è intestato allo stesso CF !!'; goto exitsp;
    end


	declare @Cd_AR				varchar(20)
	declare @Cd_ARLotto			varchar(20)
	declare @DataScadenza		smalldatetime
	declare @Cd_DOSottoCommessa	varchar(20)
	declare @Cd_ARMisura		char(2) 		
	declare @Quantita			numeric(18,8)
	declare @Cd_MG_P			char(5) 		
	declare @Cd_MGUbicazione_P	varchar(20) 	
	declare @Cd_MG_A			char(5) 		
	declare @Cd_MGUbicazione_A	varchar(20)


	select @Cd_AR				= Cd_AR				
		   , @Cd_ARLotto		= Cd_ARLotto			
		   , @DataScadenza		= (select DataScadenza from ARLotto Where Cd_AR = DoRig.Cd_AR and Cd_ARLotto = DoRig.Cd_ARLotto)
		   , @Cd_DOSottoCommessa= Cd_DOSottoCommessa	
		   , @Cd_ARMisura		= Cd_ARMisura		
		   , @Quantita			= QtaEvadibile		
		   , @Cd_MG_P			= Cd_MG_P			
		   , @Cd_MGUbicazione_P	= Cd_MGUbicazione_P	
		   , @Cd_MG_A			= Cd_MG_A			
		   , @Cd_MGUbicazione_A	= Cd_MGUbicazione_A	
	from DoRig where Id_DORig = @Id_DoRig

	if isnull(@Cd_AR, '') = '' begin
		set @r = -200; set @m = 'L''Id letto [' + cast(@Id_DoRig as varchar) + '] non ha restituito valori validi !!'; goto exitsp;
	end

												insert into @out values('Id_DORig', @Id_DoRig)
												insert into @out values('Cd_AR', @Cd_AR)
	if isnull(@Cd_ARLotto ,'') <> ''			insert into @out values('Cd_ARLotto', @Cd_ARLotto)
	if isnull(@DataScadenza ,'') <> ''			insert into @out values('DataScadenza', @DataScadenza)
	if isnull(@Cd_DOSottoCommessa, '') <> ''	insert into @out values('Cd_DOSottoCommessa', @Cd_DOSottoCommessa)
												insert into @out values('Cd_ARMisura', @Cd_ARMisura)
												insert into @out values('Quantita', @Quantita)
	if isnull(@Cd_MG_P, '') <> ''				insert into @out values('Cd_MG_P', @Cd_MG_P)
	if isnull(@Cd_MGUbicazione_P, '') <> ''		insert into @out values('Cd_MGUbicazione_P', @Cd_MGUbicazione_P)
	if isnull(@Cd_MG_A, '') <> ''				insert into @out values('Cd_MG_A', @Cd_MG_A)
	if isnull(@Cd_MGUbicazione_A, '') <> ''		insert into @out values('Cd_MGUbicazione_A', @Cd_MGUbicazione_A)

	set @r = 1
	exitsp:

		-- restituisce il risultato dei controlli 
		insert into @out values('Result', @r)
		insert into @out values('Messaggio', isnull(@m, 'Id riga letto'))
		select * from @out

	return @r
	return 
end
go

create procedure xmosp_xMORL_Del(
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar(20)		
	, @Id_xMORL				int 

)
/*ENCRYPTED*/
as begin

	-- Aggiorna lo stato della rilevazione 3 = Annullato
	Update xMORL set Stato = 3 where Id_xMORL = @Id_xMORL

	-- Memorizziamo nelle note l'elenco dei documenti prelevati per lo storico
	update xMORL set 
		NotePiede = isnull(NotePiede, '') + CHAR(13) + 'Storico prelievo: ' 
					+ (SELECT STUFF((SELECT distinct ',' + dbo.afn_FormatNumeroDoc(DoTes.Cd_Do, DoTes.NumeroDoc, DoTes.DataDoc) from DoTes inner join xMORLPrelievo on DoTes.Id_DoTes = xMORLPrelievo.Id_DoTes Where Id_xMORL = @Id_xMORL FOR XML PATH ('')), 1, 1, ''))
	where 
		Id_xMORL = @Id_xMORL

	-- Eliminazione dei documenti prelevati per dare la posibilità di cancellare i documenti collegati (Id_DOTes)
	delete from xMORLPrelievo where Id_xMORL = @Id_xMORL

end

go

create procedure xmosp_xMOTR_Del(
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar(20)		
	, @Id_xMOTR				int 

)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	
	if ISNULL(@Id_xMOTR, 0) = 0 begin
		set @r = -10; set @m = 'Errore: identificativo del trasferimento errato!'; goto exitsp;
	end

	-- Eliminazione del trasferimento
	delete from xMOTR where Id_xMOTR = @Id_xMOTR

	exitsp:

		-- restituisce il risultato dei controlli 
		select 
			Result			= @r,  
			Messaggio		= @m

	return @r

end

go

-- creazione di una procedure in cui controllo i campi del salvataggio del documento
create procedure xmosp_xMORL_Save(
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar(20)		
	, @Cd_DO				char(3)
	, @DataDoc				smalldatetime
	, @Cd_CF				char(7)
	, @Cd_CFDest			char(3)	
	, @Cd_xMOLinea			varchar(20) 
	, @NumeroDocRif			varchar(20)
	, @DataDocRif			varchar(20)
	, @Cd_MG_P				char(5)
	, @Cd_MG_A				char(5)
	, @Cd_DOSottoCommessa	varchar(20)
	, @Id_xMORL				int = null
	-- ### I prelievi vanno passati durante la creazione della testa per eseguire verifiche sia nei doc in essere in moovi che in quelli non ancora salvati nel db di arca!!
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		-- EVITA L'INSERIMENTO DI TESTE DUPLICATE: attivato solo se xMOImpostazioni.Verbose = 1. Verificare se è ancora necessario o se il problema è stato risolto
		if (select top 1 [Verbose] from xMOImpostazioni) = 1 begin
			if exists (select * from xMORL where Cd_Operatore = @Cd_Operatore And Terminale = @Terminale And Cd_DO = @Cd_DO And Stato = 0 And @Id_xMORL Is Null And TimeIns >= dateadd(SS, -120 ,getdate())) begin
				set @r = -999999; set @m = 'Generazione documento doppio!!'; goto exitsp;
			end
		end

	
		if isnull(@DataDocRif, '') = '' 
			set @DataDocRif = null;
		else
			set @DataDocRif = CONVERT(datetime, @DataDocRif, 105);

		if isnull(@DataDoc, '') = '' set @DataDoc = getdate();			

		if(@Cd_CFDest = '') set @Cd_CFDest = null

		--da rivedere la gestione della linea
		if(@Cd_xMOLinea = '') set @Cd_xMOLinea =null

		if(@Cd_MG_P = '') set @Cd_MG_P = null 
		if(@Cd_MG_A = '') set @Cd_MG_A	= null 

		-- codice cliente/forntore non vuoto
		if (isnull(@Cd_CF, '') = '') begin
			set @r = -10; set @m = 'Campo cliente/fornitore vuoto!!'; goto exitsp;
		end
		-- codice cliente/forntore
		if not exists(select * from xmofn_CF_ALL(@Terminale, @Cd_Operatore, Left(@Cd_CF, 1), @Cd_DO, null) where Cd_CF = @Cd_CF) begin
			set @r = -20; set @m = 'Campo cliente/fornitore non valido per il documento corrente!!'; goto exitsp;
		end
		-- codice destinazione deve essistere
		if  @Cd_CFDest <> '' and not exists(select * from CFDest where Cd_CFDest = @Cd_CFDest and Cd_CF = @Cd_CF) begin
			set @r = -30; set @m = 'Codice destinazione non esiste!!'; goto exitsp;
		end
		-- linea produtricce esiste
		if @Cd_xMOLinea <> '' and not exists(select * from xMOLinea where Cd_xMOLinea = @Cd_xMOLinea)  begin
			set @r = -40; set @m = 'Linea produttrice non esiste!!'; goto exitsp;
		end
		-- codice magazzino A/P devono esistere
		if  @Cd_MG_P <> '' and not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P)  begin
			set @r = -50; set @m = 'Magazzino partenza non esiste!!'; goto exitsp;
		end
		if @Cd_MG_A <> '' and not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A)  begin
			set @r = -60; set @m = 'Magazzino arrivo non esiste!!'; goto exitsp;
		end

		-- La sottocommessa deve esistere
		if isnull(@Cd_DOSottoCommessa, '') <> '' And not exists(select * from DOSottoCommessa where Cd_DOSottoCommessa = @Cd_DOSottoCommessa)  begin
			set @r = -70; set @m = 'Commessa ' + isnull(@Cd_DOSottoCommessa, '') + ' errata o inesiste!!'; goto exitsp;
		end
		
		if (isnull(@Id_xMORL, 0) = 0) begin

			Insert Into	xMORL	(Cd_DO, Terminale, Cd_Operatore, Cd_CF
								, Cd_CFDest, DataDoc, Cd_xMOLinea, NumeroDocRif
								, DataDocRif, Cd_MG_P, Cd_MG_A
								, Cd_DOSottoCommessa, Stato)
			Values				(@Cd_DO, @Terminale, @Cd_Operatore, @Cd_CF
								, @Cd_CFDest, @DataDoc, @Cd_xMOLinea, @NumeroDocRif
								, @DataDocRif, @Cd_MG_P, @Cd_MG_A
								, @Cd_DOSottoCommessa, 0 ) /* In compilazione */
			Set @id= @@IDENTITY;

		end else begin

			update xMORL set
				Cd_DO					= @Cd_DO
				  , Terminale			= @Terminale
				  , Cd_Operatore		= @Cd_Operatore
				  , Cd_CF				= @Cd_CF
				  , Cd_CFDest			= @Cd_CFDest
				  , DataDoc				= @DataDoc
				  , Cd_xMOLinea			= @Cd_xMOLinea
				  , NumeroDocRif		= @NumeroDocRif
				  , DataDocRif			= @DataDocRif
				  , Cd_MG_P				= @Cd_MG_P
				  , Cd_MG_A				= @Cd_MG_A
				  , Cd_DOSottoCommessa	= @Cd_DOSottoCommessa
				  , Stato				= 0 -- In compilazione
			where	
				Id_xMORL = @Id_xMORL

			set @id = @Id_xMORL;
		end

		set @r = (case when @id > 0 then 1 else 0 end);
		
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMORL		= @id, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
		
		return @r
end 
go

create procedure xmosp_xMORLPiede_ChiudiSpedizione (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)		
	, @Id_xMORL			int = null
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		declare @Cd_xMOCodSpe varchar(20)
		set @Cd_xMOCodSpe = (select top 1 xCd_xMOCodSpe from DOTes where Id_DoTes in (select Id_DoTes from xMORLPrelievo where Id_xMORL = @Id_xMORL))
		
		update xMOCodSpe set Attiva = 0 where Cd_xMOCodSpe = @Cd_xMOCodSpe

		set @r = @@ROWCOUNT;
		
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		select 
			Result			= @r, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
		return @r
end 
go


-- Procedura per il salvataggio del piede del RL
create procedure xmosp_xMORLPiede_Save (
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)		
	, @Id_xMORL			int = null
	, @Targa			varchar(20)
	, @Cd_DOCaricatore	char(3)
	, @PesoExtraMks		numeric(18,4)
	, @VolumeExtraMks	numeric(38,6)
	, @NotePiede		varchar(max)
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		-- Verifica esistenza RL
		if not exists(select * from xMORL where Id_xMORL = @Id_xMORL) begin
			set @r = -10; set @m = 'Identificativo della rilevazione non trovata nella tavola xMORL (' + ltrim(rtrim(str(@Id_xMORL))) + ')!!'; goto exitsp;
		end

		-- Normalizza i dati
		if isnull(@Cd_DOCaricatore, '') = '' set @Cd_DOCaricatore = null;

		if @Cd_DOCaricatore is not null  and @Cd_DOCaricatore not in(select Cd_DOSdTAnag from DOSdTAnag) begin
			set @r = -20; set @m = 'Codice caricatore non trovato!!'; goto exitsp;
		end
	

		update xMORL set
			NotePiede			= @NotePiede
			, Targa				= @Targa
			, Cd_DOCaricatore	= @Cd_DOCaricatore
			, PesoExtraMks		= @PesoExtraMks	
			, VolumeExtraMks	= @VolumeExtraMks
		where	
			Id_xMORL = @Id_xMORL

		set @id = @Id_xMORL;

		set @r = (case when @id > 0 then 1 else 0 end);
		
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMORL		= @id, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r

end 
go

-- Procedura per il salvataggio dell'avvio del consumo
create procedure xmosp_xMOConsumo_Save (
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar (20)		
	, @Cd_xMOLinea			varchar(20) 
	, @DataOra				smalldatetime
	, @Cd_AR				varchar(20) 	
	, @Cd_ARLotto			varchar(20) 	
) 
/*ENCRYPTED*/
as begin
	
	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	begin try
		
		if (isnull(@Cd_xMOLinea, '') = '') begin
			set @r = -10; set @m = 'Il campo Linea è obbligatorio!!'; goto exitsp;
		end
		if (isnull(@Cd_AR, '') = '') begin
			set @r = -20; set @m = 'Il campo Articolo è obbligatorio!!'; goto exitsp;
		end
		if (isnull(@Cd_ARLotto, '') = '') begin
			set @r = -30; set @m = 'Il campo Lotto è obbligatorio!!'; goto exitsp;
		end

		if (@DataOra is null) set @DataOra = getdate();

		insert into xMOConsumo (Terminale, Cd_Operatore, DataOra, Cd_AR, Cd_ARLotto, Cd_xMOLinea, Stato)
		values (@Terminale, @Cd_Operatore, @DataOra, @Cd_AR, @Cd_ARLotto, @Cd_xMOLinea, 0)

		set @id = (select top 1 Id_xMOConsumo from xMOConsumo order by Id_xMOConsumo desc);

		set @r = 1;

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOConsumo	= @id, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end
go

-- Procedura per il salvataggio dell'avvio del consumo
create procedure xmosp_xMOConsumoFromRL_Save (
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar (20)		
	, @Id_xMORL				int
)
/*ENCRYPTED*/
as begin
	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	set nocount on;

	begin try

		declare @Cd_xMOLinea		varchar(20) 
		declare @DataOra			smalldatetime
		declare @Cd_AR				varchar(20) 	
		declare @Cd_ARLotto			varchar(20) 	

		select @Cd_xMOLinea = Cd_xMOLinea from xMORL where Id_xMORL = @Id_xMORL
		if (isnull(@Cd_xMOLinea, '') = '') begin
			set @r = -10; set @m = 'Il campo Linea è obbligatorio!!'; goto exitsp;
		end

		set @DataOra = getdate()

		-- Cursore delle righe RL per la generazione dell'avvio consumo
		declare curRLRig CURSOR FOR   
			select distinct Cd_Ar, Cd_ARLotto from xMORLRig where Id_xMORL = @Id_xMORL And Cd_AR is not null And Cd_ARLotto is not null

		open curRLRig 

		fetch NEXT FROM curRLRig INTO @Cd_AR, @Cd_ARLotto
		while @@FETCH_STATUS = 0  
		begin  
			-- Salva l'avvio consumo per ogni riga di articolo
			exec @r = xmosp_xMOConsumo_Save @Terminale, @Cd_Operatore, @Cd_xMOLinea, @DataOra, @Cd_Ar, @Cd_ArLotto

			if (@r < 0) begin 
				set @m = 'Impossibile generare l''avvio consumo per la rilevazione ' + ltrim(rtrim(str(@Id_xMORL))) + ' per l''articolo ' + @Cd_Ar + ' del lotto ' + @Cd_ARLotto + '!!'; break;
			end

			fetch NEXT FROM curRLRig INTO @Cd_AR, @Cd_ARLotto  
		end

		CLOSE curRLRig  
		DEALLOCATE curRLRig

		if (isnull(@r, 0) >= 0) set @r = 1;

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r,
				Id_xMORL		= @Id_xMORL, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end
go

-- creazione di una procedura in cui controllo i dati di xMOTR e la salvo 
create procedure xmosp_xMOTR_Save (
	@Terminale varchar(39)
	, @Cd_Operatore varchar (20)		-- operatore 
	, @Descrizione varchar(30)			-- descrzione della movimentazione
	, @DataMov smalldatetime			-- data movimentazione
	, @Cd_MG_P char(5)					-- magazzino partenza
	, @Cd_MGUbicazione_P varchar(20)	-- ubicazione partenza
	, @Cd_MG_A char(5)					-- magazzino arrivo	
	, @Cd_MGUbicazione_A varchar(20)	-- ubicazione arrivo
	, @Cd_DOSottoCommessa varchar(20)	-- codice sottocommessa
	, @Id_xMOTR int						-- Identificativo della testa (se in edit)
	, @Cd_xMOProgramma char(2)			-- Programma con cui è stato creato il trasferimento (TI: trasf. interno, SM: Stoccaggio Merce)
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	begin try
		--campo descrizione obbligatorio
		if(isnull(@Descrizione, '') = '') begin
			set @r = -10; set @m = 'Il campo descrzione è obbligatorio!!'; goto exitsp;
		end
		--magazzino partenza
		if isnull(@Cd_MG_P, '') <> '' And not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P) begin
			set @r = -20; set @m = 'Codice magazzino ' + @Cd_MG_P + ' errato!!'; goto exitsp;
		end

		-- Verifica dell'obbligatorietà dell'ubicazione per magazzino partenza
		if isnull(@Cd_MGUbicazione_P, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P and MG_UbicazioneObbligatoria = 1) begin
			set @r = -25; set @m= 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		end
	
		-- Verifica esistenza ubicazione del magazzino partenza
		if isnull(@Cd_MGUbicazione_P, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_P And Cd_MGUbicazione = @Cd_MGUbicazione_P) begin
			set @r = -28; set @m = 'Codice ubicazione ' + @Cd_MGUbicazione_P + ' del magazzino partenza ' + @Cd_MG_P + ' errato!!'; goto exitsp;
		end

		--magazzino arrivo
		if isnull(@Cd_MG_A, '') <> '' And not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A) begin
			set @r = -30; set @m = 'Codice magazzino ' + @Cd_MG_A + ' errato!!'; goto exitsp;
		end

		-- ERRATO! Va verificato con il salvataggio delle righe di arrivo
		---- Verifica dell'obbligatorietà dell'ubicazione per magazzino arrivo
		--if isnull(@Cd_MGUbicazione_A, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A and MG_UbicazioneObbligatoria = 1) begin
		--	set @r = -35; set @m = 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		--end
	
		-- Verifica esistenza ubicazione del magazzino
		if isnull(@Cd_MGUbicazione_A, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_A And Cd_MGUbicazione = @Cd_MGUbicazione_A) begin
			set @r = -38; set @m= 'Codice ubicazione ' + @Cd_MGUbicazione_A + ' del magazzino arrivo' + @Cd_MG_A + ' errato!!'; goto exitsp;
		end

		if isnull(@DataMov, '') = '' 			set @DataMov = getdate();
		if ISNULL(@Cd_MG_P, '') = ''			set @Cd_MG_P = null;
		if ISNULL(@Cd_MGUbicazione_P, '') = ''	set @Cd_MGUbicazione_P = null;
		if ISNULL(@Cd_MG_A, '') = ''			set @Cd_MG_A = null;
		if ISNULL(@Cd_MGUbicazione_A, '') = ''	set @Cd_MGUbicazione_A = null;


		if (isnull(@Id_xMOTR, 0) = 0) begin
			insert into xMOTR (
					Terminale
					, Cd_Operatore 			
					, Descrizione 			
					, DataMov 				
					, Cd_MG_P 					
					, Cd_MGUbicazione_P		
					, Cd_MG_A 					
					, Cd_MGUbicazione_A
					, Cd_DOSottoCommessa  	
					, Cd_xMOProgramma	
					)
			values (
					@Terminale
					, @Cd_Operatore 			
					, @Descrizione 			
					, @DataMov 				
					, @Cd_MG_P 					
					, @Cd_MGUbicazione_P		
					, @Cd_MG_A 					
					, @Cd_MGUbicazione_A
					, @Cd_DOSottoCommessa 
					, @Cd_xMOProgramma
					)

			-- recupera l'id salvato
			set @id = @@IDENTITY

		end else begin

			update xMOTR set
				Terminale = @Terminale
				, Cd_Operatore = @Cd_Operatore			
				, Descrizione =	 @Descrizione	
				, DataMov =	@DataMov
				, Cd_MG_P =	@Cd_MG_P			
				, Cd_MGUbicazione_P	= @Cd_MGUbicazione_P	
				, Cd_MG_A =	@Cd_MG_A
				, Cd_MGUbicazione_A = @Cd_MGUbicazione_A
				, Cd_DOSottoCommessa = @Cd_DOSottoCommessa
			where	
					Id_xMOTR = @Id_xMOTR
		
			-- l'id salvato è quello della funzione
			set @id = @Id_xMOTR
		end

		set @r = case when @id > 0 then 1 else 0 end;
	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOTR		= @id, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

-- Procedura di inserimento di un TRASFERIMENTO di PARTENZA
create procedure xmosp_xMOTRRig_P_Save(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTR int							-- id del xMOTR
	, @Cd_AR varchar(20)					-- articolo movimentato
	, @Cd_ARLotto varchar(20)				-- lotto articolo movimentato
	, @Quantita numeric(18,8)				-- quantita del articolo
	, @Cd_ARMisura char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @Cd_MG_P char(5)						-- magazzino dove si trova articolo/lotto
	, @Cd_MGUbicazione_P varchar(20)		-- ubicazione magazzino
	, @Id_xMOTRRig_P int					-- id del xMOTRRig (Nullo se è un nuovo record)
) 
/*ENCRYPTED*/
as begin

	declare @r		int				-- risultato della sp
	declare @id		int				-- identificativo del record aggiunto
	declare @m		varchar(max)	-- Messaggio di errore
	declare @Cd_CF varchar(20)	= 'select Cd_CF From xMOTR Where Id_xMOTR = @Id_xMOTR'

	Begin try
		if not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P) begin
			set @r = -10; set @m = 'Codice magazzino partenza errato o mancante!!'; goto exitsp;
		end

		-- Verifica dell'obbligatorietà dell'ubicazione per magazzino
		if isnull(@Cd_MGUbicazione_P, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P and MG_UbicazioneObbligatoria = 1) begin
			set @r = -20; set @m= 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		end
		
		-- Verifica esistenza ubicazione del magazzino
		if isnull(@Cd_MGUbicazione_P, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_P And Cd_MGUbicazione = @Cd_MGUbicazione_P) begin
			set @r = -25; set @m= 'Codice ubicazione ' + @Cd_MGUbicazione_P + ' del magazzino ' + @Cd_MG_P + ' errato!!'; goto exitsp;
		end

		-- Per la gestione degli alias e dei codici C/F l'articolo va sempre convertito
		set @Cd_AR = (select dbo.xmofn_Get_AR_From_AAA(@Cd_AR, @Cd_CF))

		-- Verifica esistenza articolo
		if isnull(@Cd_AR, '') = '' Or not exists(select * from AR where Cd_AR = @Cd_AR) begin  -- ### per gestire ar per operatore o terminale va modificata xmofn_ARValidate in modo da passargli il top esternamente
			set @r = -30; set @m= 'Codice articolo ' + isnull(@Cd_AR, '') + ' errato!!'; goto exitsp;
		end

		-- Verifica esistenza lotto
		if isnull(@Cd_ARLotto, '') <> '' And not exists(select * from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto) begin
			set @r = -35; set @m= 'Codice lotto ' + @Cd_ARLotto + ' dell''articolo ' + @Cd_AR + ' errato!!'; goto exitsp;
		end

		-- Se cd_dosottocommessa not null verifica che l'articolo la gestisca
		declare @Cd_DOSottoCommessa varchar(20) = (select top 1 Cd_DOSottoCommessa from xMOTR where Id_xMOTR = @Id_xMOTR)
		if(isnull(@Cd_DOSottoCommessa, '') <> '' And (select TipoGestComm from AR where Cd_AR = @Cd_AR) <> 2) begin
			set @r = -38; set @m = 'L''Articolo non è del tipo Gestisci per Commessa ma il campo Cd_DoSottoCommessa risulta valorizzato in MGMov (Commessa :' + @Cd_DOSottoCommessa + ')'; goto exitsp;
		end

		-- Selezione dei parametri utili al salvataggio della rilevazione
		declare @FattoreToUM1	numeric(18,8)	-- Contiene fattore di unita di misura

		select 
			@FattoreToUM1 = UMFatt
		from 
			ARARMisura 
		where 
				Cd_AR		= @Cd_AR 
			And Cd_ARMisura = @Cd_ARMisura 

		-- Verifica il fattore di conversione
		if isnull(@FattoreToUM1, 0) = 0  begin
			set @r = -40; set @m= 'Fattore di conversione errato!!'; goto exitsp;
		end

		-- Normalizza i dati
		if ISNULL(@Cd_ARLotto, '') = ''					set @Cd_ARLotto = null;
		if ISNULL(@Cd_MGUbicazione_P, '') = ''			set @Cd_MGUbicazione_P = null;

		-- Se non è stata richiesta una modifica di un record già 
		-- presente (@Id_xMOTRRig_P is not null) viene effettuata 
		-- la ricerca dell'eventuale record già presente nella tabella
		if ISNULL(@Id_xMOTRRig_P, 0) = 0 begin
			-- se è stata inserita una riga con lo stesso articolo, lotto, magazzino 
			-- partenza e ubicazione magazzino partenza: l'articolo va sommato a quello esistente
			declare @quantF int ;

			select 
				@Id_xMOTRRig_P	 = Id_xMOTRRig_P
				, @quantF		 = Quantita
			from 
				xMOTRRig_P
			where
					Id_xMOTR = @Id_xMOTR
				And	Cd_AR = @Cd_AR 
				And isnull(Cd_ARLotto, '') = isnull(@Cd_ARLotto, '') 
				And Cd_MG_P	= @Cd_MG_P 
				And isnull(Cd_MGUbicazione_P, '') = isnull(@Cd_MGUbicazione_P, '') 

			if(isnull(@quantF,0)<>0) set @Quantita = @Quantita + @quantF;
		end
		
		if ISNULL(@Id_xMOTRRig_P, 0) > 0 begin

			-- Aggiorna il record esistente
			update xMOTRRig_P set
				Cd_AR				= @Cd_AR
				, Cd_ARLotto		= @Cd_ARLotto
				, Cd_ARMisura		= @Cd_ARMisura
				, FattoreToUM1		= @FattoreToUM1
				, Quantita			= @Quantita
				, DataOra			= GETDATE()
				, Cd_MG_P			= @Cd_MG_P
				, Cd_MGUbicazione_P = @Cd_MGUbicazione_P
				, Terminale			= @Terminale
				, Cd_Operatore		= @Cd_Operatore
			where	
				Id_xMOTRRig_P = @Id_xMOTRRig_P

			set @id = @Id_xMOTRRig_P;

		end	else begin			
		
			-- Inserisco il nuovo record

			insert into xMOTRRig_P (
				Id_xMOTR
				, Cd_AR
				, Cd_ARLotto
				, Cd_ARMisura
				, FattoreToUM1
				, Quantita
				, DataOra
				, Cd_MG_P
				, Cd_MGUbicazione_P
				, Terminale
				, Cd_Operatore
				)
			values (
				@Id_xMOTR
				, @Cd_AR
				, @Cd_ARLotto
				, @Cd_ARMisura
				, @FattoreToUM1
				, @Quantita
				, getdate()
				, @Cd_MG_P
				, @Cd_MGUbicazione_P
				, @Terminale
				, @Cd_Operatore
				)
		
			set @id = @@IDENTITY;
			
		end

		set @r = case when @id > 0 then 1 else 0 end;

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Id_xMOTRRig_P = @id, Messaggio = isnull(@m, 'Inserimento effettuato con successo.')
		return @r

end 
go

-- Delete dell'ultima lettura effettuata (la recupera dall'id della testa la sp)
create procedure xmosp_xMOTRRig_P_Last_Del(					
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)
	, @Id_xMOTR_Del		int		
)
/*ENCRYPTED*/
as begin	
	-- Elimina l'ultima lettura
	declare @r				int				-- risultato della sp
	declare @Id_xMOTRRig_P	int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		declare @Id_xMOTRRig_P_Del int

		-- Seleziona l'ultima riga letta
		set @Id_xMOTRRig_P_Del = (select top 1 Id_xMOTRRig_P from xMOTRRig_P where Id_xMOTR = @Id_xMOTR_Del order by 1 desc)

		delete from xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P_Del
		set @Id_xMOTRRig_P	= @Id_xMOTRRig_P_Del
		set @r				= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOTRRig_P	= @Id_xMOTRRig_P_Del, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')
		return @r
end 
go

-- Delete di una lettura effettuata nel TR di PARTENZA
create procedure xmosp_xMOTRRig_P_Del(
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)		
	, @Id_xMOTRRig_P_Del	int 					
)
/*ENCRYPTED*/
as begin	

	declare @r				int				-- risultato della sp
	declare @Id_xMOTRRig_P	int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		delete from xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P_Del
		set @Id_xMOTRRig_P	= @Id_xMOTRRig_P_Del
		set @r				= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOTRRig_P	= @Id_xMOTRRig_P, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')
		return @r
end 
go

create procedure xmosp_xMOTRRig_A_Save(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTR int							-- id del xMOTR
	, @Id_xMOTRRig_P int					-- id del xMOTRRig_P 
	, @Quantita numeric(18,8)				-- quantita del articolo
	, @Cd_ARMisura char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @Cd_MG_A char(5)						-- magazzino dove si trova articolo/lotto
	, @Cd_MGUbicazione_A varchar(20)		-- ubicazione magazzino
	, @Id_xMOTRRig_A int					-- id opzionale per l'update
) 
/*ENCRYPTED*/
as begin

	declare @r		int				-- risultato della sp
	declare @id		int				-- identificativo del record aggiunto
	declare @m		varchar(max)	-- Messaggio di errore

	Begin try
		if not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A) begin
			set @r = -10; set @m = 'Codice magazzino di arrivo errato o mancante!!'; goto exitsp;
		end

		-- Verifica dell'obbligatorietà dell'ubicazione per magazzino
		if isnull(@Cd_MGUbicazione_A, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A and MG_UbicazioneObbligatoria = 1) begin
			set @r = -20; set @m= 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		end
		
		-- Recupera il codice articolo dal TR di partenza
		declare @Cd_AR varchar(20)
		set @Cd_AR = (select Cd_AR from xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P)

		-- Verifica esistenza ubicazione del magazzino
		if isnull(@Cd_MGUbicazione_A, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_A And Cd_MGUbicazione = @Cd_MGUbicazione_A) begin
			set @r = -25; set @m = 'Codice ubicazione ' + @Cd_MGUbicazione_A + ' del magazzino ' + @Cd_MG_A + ' errato!!'; 
			goto exitsp;
		end

		if ISNULL(@Cd_MGUbicazione_A, '') = ''			set @Cd_MGUbicazione_A = null;


		declare @Qta_P_UM1		numeric(18,8)	
		-- Memorizza l'intera quantità di partenza nel UM principale
		set @Qta_P_UM1 = (select Quantita * FattoreToUM1 from xMOTRRig_P where Id_xMOTRRig_P	= @Id_xMOTRRig_P)


		declare @FattoreToUM1_A	numeric(18,8)	-- Contiene fattore di unita di misura
		declare @Qta_A_UM1		numeric(18,8)	

		select 
			@FattoreToUM1_A = UMFatt
		from 
			ARARMisura 
		where 
				Cd_AR		= (Select Cd_Ar From xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P)
			And Cd_ARMisura = @Cd_ARMisura


		-- Calcola l'intera quantità assegnata dell'articolo corrente
		select
			@Qta_A_UM1 = SUM(a.Quantita * a.FattoreToUM1)
		from
			xmofn_xMOTRRig_A(@Terminale, @Cd_Operatore) a
		where 
				a.Id_xMOTR		= @Id_xMOTR
			And	a.Id_xMOTRRig_P = @Id_xMOTRRig_P
		group by
			a.Id_xMOTRRig_P
		
		-- controllo della quantità da decurtare
		if isnull(@Qta_A_UM1, 0) = 0 set @Qta_A_UM1 = 0
		if (@Qta_A_UM1 + (@Quantita * @FattoreToUM1_A) > @Qta_P_UM1) begin
			set @r = -30; set @m = 'quantita da movimentare (' + ltrim(str(@Quantita, 18, 2)) + ') maggiore di quella residua (' + ltrim(str(((@Qta_P_UM1 - @Qta_A_UM1) / @FattoreToUM1_A), 18, 2)) + ') di partenza!!'; 
			goto exitsp;
		end	


		declare @Totqua int
		if isnull(@Id_xMOTRRig_P, 0) = 0 begin 
			select 
				@Totqua = Quantita
				, @Id_xMOTRRig_A = Id_xMOTRRig_A
			from 
				xmofn_xMOTRRig_A(@Terminale, @Cd_Operatore) 
			where
				Id_xMOTR	= @Id_xMOTR and
				Cd_MG_A		= @Cd_MG_A and 
				(Cd_MGUbicazione_A = @Cd_MGUbicazione_A or Cd_MGUbicazione_A is null) and
				Id_xMOTRRig_P = @Id_xMOTRRig_P
				
			
			if ISNULL(@Totqua,0) <> 0  
				set @Quantita = @Quantita + @Totqua
		end		
					
		if (isnull(@Id_xMOTRRig_A, 0) = 0) begin 
		
			-- Inserisco il nuovo record

			insert into xMOTRRig_A(
				Id_xMOTR
				, Terminale
				, Cd_Operatore
				, Id_xMOTRRig_P
				, Cd_ARMisura
				, FattoreToUM1
				, Quantita
				, DataOra
				, Cd_MG_A
				, Cd_MGUbicazione_A
				)
			values (
				@Id_xMOTR
				, @Terminale
				, @Cd_Operatore
				, @Id_xMOTRRig_P
				, @Cd_ARMisura
				, @FattoreToUM1_A
				, @Quantita
				, GETDATE()
				, @Cd_MG_A
				, @Cd_MGUbicazione_A
			 	)
		
			set @id = @@IDENTITY;
			set @r = case when @id > 0 then 1 else 0 end;

		end else begin
			
			-- Aggiorna il record esistente
			update xMOTRRig_A  set
				Terminale			= @Terminale
				, Cd_Operatore		= @Cd_Operatore
				, Id_xMOTRRig_P		= @Id_xMOTRRig_P
				, Cd_ARMisura		= @Cd_ARMisura
				, FattoreToUM1		= @FattoreToUM1_A
				, Quantita			= @Quantita
				, Cd_MG_A			= @Cd_MG_A
				, Cd_MGUbicazione_A = @Cd_MGUbicazione_A
			where	
				Id_xMOTRRig_A = @Id_xMOTRRig_A

			set @id = @Id_xMOTRRig_P;
			set @r = case when @id > 0 then 1 else 0 end;

		end

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); 
		goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Id_xMOTRRig	= @id, Messaggio = isnull(@m, 'Inserimento effettuato con successo.')
		return @r

end 
go

create procedure xmosp_xMOTRRig_A_Last_Del(
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)
	, @Id_xMOTR_Del		int		
)
/*ENCRYPTED*/
as begin	
	-- Elimina l'ultima lettura
	declare @r				int				-- risultato della sp
	declare @Id_xMOTRRig_A	int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		declare @Id_xMOTRRig_A_Del int

		-- Seleziona l'ultima riga letta
		set @Id_xMOTRRig_A_Del = (select top 1 Id_xMOTRRig_A from xMOTRRig_A where Id_xMOTR = @Id_xMOTR_Del order by 1 desc)

		delete from xMOTRRig_A where Id_xMOTRRig_A = @Id_xMOTRRig_A_Del
		set @Id_xMOTRRig_A	= @Id_xMOTRRig_A_Del
		set @r				= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOTRRig_A	= @Id_xMOTRRig_A_Del, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')
		return @r
end 
go

-- Delete di una lettura effettuata nel TR in arrivo
create procedure xmosp_xMOTRRig_A_Del(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTRRig_A int					-- id del xMOTRRig (Nullo se è un nuovo record)
	
)
/*ENCRYPTED*/
as begin

	declare @r		int				-- risultato della sp
	declare @id		int				-- cancellazione del record effetuato
	declare @m		varchar(max)	-- Messaggio di errore

	begin try

		delete xMOTRRig_A where Id_xMOTRRig_A = @Id_xMOTRRig_A 

		set @id = 0;
		set @r  = 1;
	
	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Id_xMOTRRig_P = @id, Messaggio = isnull(@m, 'Cancellazione effettuato con successo.')
	return @r
end 
go

-- Procedura per il salvataggio del piede del TR
create procedure xmosp_xMOTRPiede_Save (
	@Terminale		varchar(39)
	, @Cd_Operatore	varchar(20)		
	, @Id_xMOTR		int 
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		-- Verifica esistenza TR
		if not exists(select * from xMOTR where Id_xMOTR = @Id_xMOTR) begin
			set @r = -10; set @m = 'Identificativo del trasferimento non trovato nella tavola xMOTR (' + ltrim(rtrim(str(@Id_xMOTR))) + ')!!'; goto exitsp;
		end

		-- PER ORA NON DEVO FARE NULLA SUL PIEDE

		set @id = @Id_xMOTR;

		set @r = (case when @id > 0 then 1 else 0 end);
		
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMOTR		= @id, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

-- Delete dell'articolo nell'unità logistica delle letture effettuate
create procedure xmosp_xMORLRigPackList_Del(					
	@Terminale					varchar(39)		
	, @Cd_Operatore				varchar(20)
	, @Id_xMORLRigPackList_Del	int	
	, @Qta_Del					numeric(18,8)	
)
/*ENCRYPTED*/
as begin	
	-- Elimina l'ultima lettura
	declare @r		int				-- risultato della sp
	declare @id		int				-- identificativo del record RL corrispondente eliminato
	declare @m		varchar(max)	-- Messaggio di errore

	begin try

		if(@Qta_Del = 0) begin
			set @r = -10; set @m = 'Quantita da eliminare zero!!'; goto exitsp;
		end 

		declare @Id_xMORLRig	int
		declare @RLQta			numeric(18,8)
		declare @PkQta			numeric(18,8)
		-- Seleziona l'id riga correlato da eliminare
		select 
			@Id_xMORLRig	= xMORLRig.Id_xMORLRig 
			, @RLQta		= xMORLRig.Quantita
			, @PkQta		= xMORLRigPackList.Qta
		from 
			xMORLRigPackList inner join xMORLRig on xMORLRigPackList.Id_xMORLRig = xMORLRig.Id_xMORLRig
		where 
			Id_xMORLRigPackList = @Id_xMORLRigPackList_Del 


		if(@Qta_Del > @PkQta) begin
			set @r = -20; set @m = 'Quantita da eliminare > della quantità totale!!'; goto exitsp;
		end 

		-- Packing
		if (@Qta_Del = @PkQta) begin
			-- La quantità da eliminare è pari al totale: elimino la packing
			delete from xMORLRigPackList where Id_xMORLRigPackList = @Id_xMORLRigPackList_Del
		end else begin 
			-- La quantità da eliminare è minore del totale: aggiorno la quantità decurtandola
			update xMORLRigPackList set Qta = Qta - @Qta_Del where Id_xMORLRigPackList = @Id_xMORLRigPackList_Del
		end
		-- Rilevazioni
		if (@Qta_Del = @RlQta) begin
			-- La quantità da eliminare è pari al totale: elimino la RL
			delete from xMORLRig where id_xMORLRig = @Id_xMORLRig
		end else begin 
			-- La quantità da eliminare è minore del totale: aggiorno la quantità decurtandola in RL
			update xMORLRig set Quantita = Quantita - @Qta_Del where Id_xMORLRig = @Id_xMORLRig
		end

		set @Id		= @Id_xMORLRig
		set @r		= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMORLRig		= @id, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')

		return @r
end 
go

create procedure xmosp_xMORLRigPackList_Shift(
	@Terminale					varchar(39)
	, @Cd_Operatore				varchar(20)
	, @Id_xMORLRigPackList		int				
	, @PackListRef_New			varchar(20)		
	, @Qta_New					numeric(18,8)	
)
/*ENCRYPTED*/
as begin

	declare @r		int				-- risultato della sp
	declare @id		int				-- cancellazione del record effetuato
	declare @m		varchar(max)	-- Messaggio di errore


	declare @Id_xMORLRigPackList_To		int
	declare @QtaTot						numeric(18,8)
	declare @Id_xMORLRig				int

	Begin try

		Select 
			@QtaTot = Qta 
			, @Id_xMORLRig = Id_xMORLRig
		From 
			xMORLRigPackList 
		Where 
			Id_xMORLRigPackList = @Id_xMORLRigPackList
		
		if(@Qta_New > @QtaTot) begin
			set @r = -10; set @m = 'Quantita da spostare > della quantità totale!!'; goto exitsp;
		end 
		
		if(@PackListRef_New = (select PackListRef from xMORLRigPackList where Id_xMORLRigPackList = @Id_xMORLRigPackList)) begin
			set @r = -20; set @m = 'Attenzione l''unità logistica non può corrispondere a quella di partenza!!'; goto exitsp;
		end 
		
		-- Cerco l'UL di destinae: se esite devo fare update e mai insert into
		select 
			@Id_xMORLRigPackList_To = Id_xMORLRigPackList
		from
			 xMORLRigPackList
		where 
			PackListRef = @PackListRef_New And
			Id_xMORLRig = @Id_xMORLRig


		-- Controllo se la quantità da spostare corrisponde alla totale 
		if (@Qta_New = @QtaTot) begin
			-- Se non esiste già una riga di destinazione per l'UL di destinazione scelta allora aggiorno la riga di partenza
			if @Id_xMORLRigPackList_To is null begin
				-- La qta viene spostata interamente: aggiorno semplicemente l'UL
				update xMORLRigPackList set PackListref = @PackListRef_New where Id_xMORLRigPackList = @Id_xMORLRigPackList
			-- Nel caso in cui esistegià una riga per l'UL di arrivo aggiorno la riga aggiungendo qta_new e elimino la riga di partenza
			end else begin
				-- La qta viene spostata interamente su una riga UL esistente: aggiorno la quantità e elimino l'UL di partenza
				update xMORLRigPackList set Qta = Qta + @Qta_New where Id_xMORLRigPackList = @Id_xMORLRigPackList_To
				delete from xMORLRigPackList  where Id_xMORLRigPackList = @Id_xMORLRigPackList 
			end

			set @id = @Id_xMORLRigPackList
		
		end else begin	
			
			-- Sposto una quotaparte della quantità: aggiorno l'UL corrente decurtando la Qta e inserisco la Qta spostata nella nuova UL
			update xMORLRigPackList set Qta = Qta - @Qta_New  where Id_xMORLRigPackList = @Id_xMORLRigPackList

			-- Se non è presente una riga per quell'Ul inserisco una nuvoa riga 
			if @Id_xMORLRigPackList_To is null begin
				insert into xMORLRigPackList (Id_xMORLRig, PackListRef, Qta)
				select 
					@Id_xMORLRig
					, @PackListRef_New
					, @Qta_New
				
				set @id = @@IDENTITY
			-- se esiste già una riga per l'UL di arrivo passata alla sp aggiorno la riga esistente 
			end else begin 
				update xMORLRigPackList set Qta = Qta + @Qta_New where Id_xMORLRigPackList = @Id_xMORLRigPackList_To

				set @id = @Id_xMORLRigPackList_To
			end
		end
		set @r = 1
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

exitsp:
	-- restituisce il risultato dei controlli 
	select 
		Result				= @r, 
		Id_xMORLRigPackList	= @id, 
		Messaggio			= isnull(@m, 'Spostamento effettuato con successo.')

	return @r
end 
go

-- Aggiunge/Aggiorna i prelievi associati ad una testa di RL
create procedure xmosp_xMORLPrelievo_Save(
	 @Terminale			varchar(39) 
	 , @Cd_Operatore	varchar(20) 
	 , @Id_xMORL		int			
	 , @Id_DOTess		varchar(max)		-- Elenco dei documenti selezionata separati da ","
	 , @m				varchar(max) output
)
/*ENCRYPTED*/
as begin
	begin try
		declare @r		int				-- risultato della sp
		declare @id		int				-- cancellazione del record effetuato
		--declare @m		varchar(max)	-- ATTENZIONE! Messaggio di errore è passato alla funzione

		-- La stringa dei prelievi deve iniziare e finire con "," e non deve contenere spazi!
		set @Id_DOTess = 
						case when left(@Id_DOTess, 1) <> ',' then ',' else '' end		-- Virgola iniziale
						+ replace(@Id_DOTess, ' ', '')									-- elimina gli spazi
						+ case when right(@Id_DOTess, 1) <> ',' then ',' else '' end	-- Virgola finale

		-- Verifico che il prelievo non sia già stato occupato 
		declare @Id_xMORL_Bloccato int
		set @Id_xMORL_Bloccato = (select dbo.xmofn_xMORLPrelievo_Test(@Id_xMORL, @Id_DOTess))
		if(isnull(@Id_xMORL_Bloccato, 0) > 0) begin
			set @r = -111; set @m = 'Attenzione! Il prelievo che si vuole effettuare è già impegnato da: ' + dbo.xmofn_xMORL_Info(@Id_xMORL_Bloccato) + '!!'; goto exitsp;
		end

		declare @t as table(Id_DOTes int, Id_DORig int, Cd_AR varchar(20))

		-- Carica tutti i documenti prelevabili nella tabella temporanea
		insert into @t (Id_DOTes, Id_DORig, Cd_AR)
		select 
			Id_DOTes
			, Id_DORig
			, Cd_AR
		from
			DORig 
		Where 
			-- Righe non evase
				QtaEvadibile > 0
			And DORig.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))


		-- Eliminazione di tutti i prelievi non presenti nell'elenco Id_DOTess
		delete from
			 xMORLPrelievo 
		Where 
  				Id_xMORL = @Id_xMORL 
				-- Righe non presenti nella lista
			and Id_DORig not in (select Id_DORig from @t)

		-- Aggiungo tutte le righe (se non presenti)		
		insert into xMORLPrelievo (Id_xMORL, Id_DOTes, Id_DORig)
		select
			Id_xMORL = @Id_xMORL
			, r.Id_DOTes
			, r.Id_DORig
		from 
			@t r
		where
			r.Id_DORig not in (select Id_DORig from xMORLPrelievo where Id_xMORL = @Id_xMORL)

		-- Variabile di test per la verifica delle righe inserite
		declare @n int
		set @n = @@ROWCOUNT

		-- Verifica che il prelievo non ammette fuorilista
		Declare @Fuorilista bit
		Set @Fuorilista = (Select xMOFuorilista From DO where Cd_DO = (Select Cd_DO From xMORL Where Id_xMORL = @Id_xMORL))
		-- Se esiste il prelievo e i fuori lista non sono ammessi
		if (@n > 0) And (@FuoriLista = 0) begin
			-- Fuorilista non ammessi: elimino tutti i record non coerenti con il prelievo
			delete from xMORLRig
			where 
					-- Stessa testa di mooovi
					Id_xMORL = @Id_xMORL
					-- Articoli non presenti in moovi
				And Cd_AR not in (select distinct Cd_AR from @t)

		end

		set @id = @Id_xMORL;
		set @r  = 1999;
	
	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch
	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Id_xMORL = @id, Messaggio = isnull(@m, 'Salvataggio prelievi effettuato con successo.')

		return @r;
end
go

-- Dopo aver validato i prelievi li salva creando RL
create procedure xmosp_xMORLPrelievo_SaveRL(
	 @Terminale		varchar(39) 
	 , @Cd_Operatore	varchar(20) 
	 , @Cd_DO			char(3)				-- Documento da generare
	 , @Id_DOTess		varchar(max)		-- Elenco dei documenti selezionata per il prelievo separati da ","
	 , @Id_xMORL		int					-- Identificativo del RL (se nullo esegue addnew)
)
/*ENCRYPTED*/
as begin
	begin try

		declare @r		int				-- risultato della sp
		declare @id		int				-- Id RL creato
		declare @m		varchar(max)	-- Messaggio di errore

		if (ISNULL(@Cd_DO, '') = '') begin
			set @r = -10; set @m = 'Documento da generare errato o mancante!!'; goto exitsp;
		end

		if (ISNULL(@Id_DOTess, '') = '') begin
			set @r = -20; set @m = 'Nessun documento da prelevare selezionato!!'; goto exitsp;
		end
		
		-- La stringa dei prelievi deve iniziare e finire con "," e non deve contenere spazi!
		set @Id_DOTess = 
						case when left(@Id_DOTess, 1) <> ',' then ',' else '' end		-- Virgola iniziale
						+ replace(@Id_DOTess, ' ', '')									-- elimina gli spazi
						+ case when right(@Id_DOTess, 1) <> ',' then ',' else '' end	-- Virgola finale
		
		-- controlla per sicurezza se la query che restituisce il CF restituisce più di un valore (il controllo viene fatto già dalla validate)
		-- ma viene ripetuto per evitare che l'assegnazione sottostante vada in errore
		if((Select count(distinct Cd_CF) from DOTes where DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))) > 1)begin
			set @r = -25; set @m = 'Non è possibile prelevare documenti intestati a clienti/fornitori diversi'; goto exitsp;
		end

		-- Recupera il CF
		Declare @Cd_CF	char(7)				-- C/F
		set @Cd_CF = (Select distinct top 1 Cd_CF from DOTes where DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess)))
		if (ISNULL(@Cd_CF, '') = '') begin
			set @r = -30; set @m = 'Nessun Cliente/Fornitore presente nei prelievi selezionati!!'; goto exitsp;
		end
		
		declare @t as table(Id_DOTes int, Cd_DO char(3), Cd_CFDest char(3), Targa varchar(20), Cd_DOSottoCommessa varchar(20), xCd_xMOCodSpe varchar(15))

		-- Carica tutti i documenti prelevabili nella tabella temporanea
		insert into @t (Id_DOTes, Cd_DO, Cd_CFDest, Targa, Cd_DOSottoCommessa, xCd_xMOCodSpe)
		select 
			Id_DOTes, Cd_DO, Cd_CFDest, xTarga, Cd_DOSottoCommessa, xCd_xMOCodSpe
		from
			DOTes
		Where 
			DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))

		-- Recupera tutti i dati coerenti dai prelievi
		declare @Cd_CFDest				char(3)			-- CFDest se selezionato come univoco nella coerenza dei doc.
		declare @Targa					varchar(20)
		declare @Cd_DOSottoCommessa		varchar(20)
		declare @Cd_xMOCodSpe			varchar(15)

		-- Un solo record: coerenza delle SO
		if (select isnull(count(*), 0) from (select distinct Cd_CFDest from @t) p) = 1					set @Cd_CFDest = (select distinct Cd_CFDest from @t);
		-- Un solo record: coerenza della targa
		if (select isnull(count(*), 0) from (select distinct Targa from @t) p) = 1						set @Targa = (select distinct Targa from @t);
		-- Un solo record: coerenza della sottocommessa
		if (select isnull(count(*), 0) from (select distinct Cd_DOSottoCommessa from @t) p) = 1			set @Cd_DOSottoCommessa = (select distinct Cd_DOSottoCommessa from @t);
		-- Un solo record: coerenza della spedizione
		if (select isnull(count(*), 0) from (select distinct xCd_xMOCodSpe from @t) p) = 1				set @Cd_xMOCodSpe = (select distinct xCd_xMOCodSpe from @t);

		-- Recuperare i codici magazzino
		declare @Cd_MG_P char(5)
		declare @Cd_MG_A char(5)
		select @Cd_MG_P	= MGCausale_Cd_MG_P, @Cd_MG_A = MGCausale_Cd_MG_A from dbo.DOTes_Defaults(@Cd_DO, @Cd_CF, getdate())

		begin transaction tran_GenRL

			if (isnull(@Id_xMORL, 0) = 0) begin
				
				--ADDNEW
				
				declare @rl as table (Result int, Id_xMORL int, Messaggio varchar(max))
			
				-- Creazione della testa di RL  (Cd_xMOLinea, NumeroDocRif, DataDocRif)
				insert into @rl (Result, Id_xMORL, Messaggio)

				exec xmosp_xMORL_Save 	@Terminale				
										, @Cd_Operatore					
										, @Cd_DO	
										, null		-- @DataDoc ### creare l'interfaccia in moovi per permettere l'inserimento della data all'operatore			
										, @Cd_CF				
										, @Cd_CFDest			
										, null		-- @Cd_xMOLinea			 
										, null		-- @NumeroDocRif			
										, null		-- @DataDocRif			
										, @Cd_MG_P				
										, @Cd_MG_A				
										, @Cd_DOSottoCommessa
										, @Id_xMORL				

				-- Verifica il risultato
				if ((select top 1 Result from @rl) <> 1) begin
					select top 1 @r = Result, @m = Messaggio from @rl; goto exitsp;
				end

				--Recupera l'id salvato
				set @id = (select top 1 Id_xMORL from @rl)

			end else begin
				--EDIT: L'id è la testa già salvata
				set @id = @Id_xMORL
			end

			-- Salva il codice spedizione
			update xMORL set Cd_xMOCodSpe = @Cd_xMOCodSpe, Targa = @Targa where Id_xMORL = @id

			-- Creazione dei prelievi associati alla nuova testa di RL (se @r < 0 esce con errore)
			exec @r = xmosp_xMORLPrelievo_Save @Terminale, @Cd_Operatore, @id, @Id_DOTess, @m output
			if (@r < 0) goto exitsp;
			
			--Tutto Ok
			set @r = 1;

		commit transaction tran_GenRL

	end try
	Begin catch 
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch
	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Id_xMORL = @id, Messaggio = isnull(@m, 'RL salvata con successo.')
		return @r	
end
go

-- Valida i prelievi selezionati da un operatore per la creazione di una RL
-- Restituisce:
--				0<	Errore
--				1	Tutto ok
--				2	Richiesta conferma dall'operatore per incoerenza dati di testa (### da sviluppare)
create procedure xmosp_xMORLPrelievo_Validate(
	 @Terminale		varchar(39) 
	 , @Cd_Operatore	varchar(20) 
	 , @Cd_DO			char(3)				-- Documento da generare
	 , @Id_DOTess		varchar(max)		-- Elenco dei documenti selezionata per il prelievo separati da ","
)
/*ENCRYPTED*/
as begin
	begin try
		declare @r			int				-- risultato della sp
		declare @m			varchar(max)	-- Messaggio di errore

		if (ISNULL(@Cd_DO, '') = '') begin
			set @r = -10; set @m = 'Documento da generare errato o mancante!!'; goto exitsp;
		end

		if (ISNULL(@Id_DOTess, '') = '') begin
			set @r = -20; set @m = 'Nessun documento da prelevare selezionato!!'; goto exitsp;
		end
		
		-- La stringa dei prelievi deve iniziare e finire con "," e non deve contenere spazi!
		set @Id_DOTess = 
						case when left(@Id_DOTess, 1) <> ',' then ',' else '' end		-- Virgola iniziale
						+ replace(@Id_DOTess, ' ', '')									-- elimina gli spazi
						+ case when right(@Id_DOTess, 1) <> ',' then ',' else '' end	-- Virgola finale

		declare @t as table(Id_DOTes int, Cd_DO char(3), Cd_CFDest char(3))

		-- Carica tutti i documenti prelevabili nella tabella temporanea
		insert into @t (Id_DOTes, Cd_DO, Cd_CFDest)
		select 
			Id_DOTes, Cd_DO, Cd_CFDest
		from
			DOTes
		Where 
			-- DEPRECATA --> charindex(',' + ltrim(str(DOTes.Id_DOTes)) + ',', @Id_DOTess) > 0
			DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))

		-- Verifica la tipologia di documento da creare: se esistono doumenti senza do associati per il prelievo @Cd_DO non è corretto per il tipo di prelievo scelto
		if exists(select * from @t t left join (select Cd_DO_Prelevabile from DODOPrel where DODOPrel.Cd_DO = @Cd_DO) p on p.Cd_DO_Prelevabile = t.Cd_DO where p.Cd_DO_Prelevabile is null) begin
			-- Esistono record che non prelevano
			set @r = - 30; set @m = 'Documenti incoerenti per il prelievo!!'; goto exitsp;
		end
		
		-- Verifica coerenza dati di testa dei doc
		declare @nRec int
		declare @ErrMsg varchar(60)

		select 
			@nRec = isnull(count(*), 0)
			, @ErrMsg = 
				case	
					when count(distinct Cd_CF)		> 1 then 'Codici cliente/fornitore diversi'
					when count(distinct Cd_PG)		> 1 then 'Codici pagamento diversi'
					when count(distinct ScontoCassa)> 1 then 'Sconto cassa diverso'
					when count(distinct DataPag)> 1 then 'Date pagamento diverse'
				else '' end
		from
			( 
			select distinct
				Cd_CF
				, Cd_CF_Fatt
				, Cd_VL
				, ScontoCassa
				, TipoFattura
				, AccontoV
				, AccontoFissoV
				, DataPag
				, Cd_PG
			from 
				DOTes 
			where
				Id_DOTes in (select Id_DOTes from @t)
			) p

		-- A seconda dei dati selezionati verifico la coerenza
		select @r = 
			case 
				when @nRec = 0	then 0
				when @nRec = 1	then 1
				when @nRec > 1 then 2
				else 0 
			end		

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch
	exitsp:
		-- restituisce il risultato dei controlli con una select
		select Result = @r, Messaggio = case when @r = 2 then 'Prelievi incoerenti. ' + @ErrMsg else isnull(@m, 'Prelievi verificati con successo.') end
		return @r
end
go

create procedure xmosp_ListenerCoda_Add(
	@Terminale			varchar(39) 
	, @Cd_Operatore		varchar(20)
	, @Cd_xMOListener	varchar(64)
	, @Comando			varchar(max)
	, @Id_xMORL			int				-- Identificativo del documento che ha fatto scaturire la richiesta RL
	, @Id_xMOTR			int				-- Identificativo del documento che ha fatto scaturire la richiesta TR
)
/*ENCRYPTED*/
as begin

	declare @r		int				-- risultato della sp
	declare @id		int				-- cancellazione del record effetuato
	declare @m		varchar(max)	-- Messaggio di errore

	Begin try

		-- Se gli id sono zero li imposta a null
		set @Id_xMORL = case when ISNULL(@Id_xMORL, 0) = 0 then null else @Id_xMORL end
		set @Id_xMOTR = case when ISNULL(@Id_xMOTR, 0) = 0 then null else @Id_xMOTR end

		Insert Into xMOListenerCoda (
					Terminale, Cd_Operatore, Cd_xMOListener, DataOra	
					, Comando, Id_xMORL, Id_xMOTR, Stato	
					)
		Values (
					@Terminale, @Cd_Operatore, @Cd_xMOListener, getdate()	
					, @Comando, @Id_xMORL, @Id_xMOTR, 0
				)
	
		set @r = 1;
		set @id = @@IDENTITY;

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); 
		goto exitsp;
	End Catch

	exitsp:
		select Result = @r, Id_xMOListenerCoda = @id, [Message] = isnull(@m, 'Comando aggiunto alla coda.')
		return @r
end
go

create procedure xmosp_ListenerDevice_Add(
	@Cd_xMOListener		varchar(64)
	, @Devices			xml -- Elenco dei device (esempio: '<rows><row device="FAX" /><row device="Primo pdf" /><row device="EdoARTO" /></rows>')
)
/*ENCRYPTED*/
as begin
	
	-- Elimina i device che non sono presenti nella lista
	delete from xMOListenerDevice
	where
			Cd_xMOListener = @Cd_xMOListener
		And Device not in (
							Select 
								Device	= r.value('@device'	, 'char(220)')
							From 
								@Devices.nodes('/rows/row') as x(r)
						)

	-- Aggiunge tutti i device non presenti in lista
	insert into xMOListenerDevice (Cd_xMOListener, Device)
	select 
		Cd_xMOListener	= @Cd_xMOListener
		, Device		= r.value('@device'	, 'char(220)')
	From 
		@Devices.nodes('/rows/row') as x(r)
	where
		r.value('@device'	, 'char(220)') not in (
							Select 
								Device	
							From 
								xMOListenerDevice
							Where 
								Cd_xMOListener	= @Cd_xMOListener
						)
	return 
end
go

-- Procedura di generazione matricole
create procedure xmosp_Matricola_Save(
	@Cd_xMOListener	varchar(64)		
	, @Cd_xMOLinea	varchar(20)		
)
/*ENCRYPTED*/
as begin
	-- Return:
	--	>= 0: End OK (1  Nothing To Do)
	--	 < 0: End Failed
	--	  -1: Id non Valido
	--	  -2: Errore inserimento testa
	--	  -3: Errore inserimento riga
	--	  -4: Errore inserimento matricola

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	declare @rdoe			int				-- risultato di ASP_DOEND

	Begin try

		-- IMPOSTAZIONI .......................................................................................

		-- Carica le impostazioni di MOOVI per i carichi
		declare @Cd_DO			char(3) 
		declare @Cd_CF			char(7) 
		declare @Cd_ARMisura	char(2) 
		declare @Cd_MG			char(5)

		select top 1 @Cd_DO = MatCd_DO, @Cd_CF = MatCd_CF, @Cd_ARMisura = MatCd_ARMisura from xMOImpostazioni
	
		if (@Cd_DO is null Or @Cd_CF is null Or @Cd_ARMisura is null) begin
			set @r = -10; set @m = 'Impostazioni di generazione Carichi per Matricola errate!!'; goto exitsp;
		end

		-- Carica il magazzino dalla linea
		select @Cd_MG = Cd_MG from xMOLinea where Cd_xMOLinea = @Cd_xMOLinea

		-- Carica la parametrizzazione dei P/C
		DECLARE @CreaConPC				bit
							-- Crea il documento con P/C se le impostazioni di Moovi e il documento li contemplano attivi 
		select @CreaConPC = (select top 1 MatPC from xMOImpostazioni) & (select UIAbilitaTipoPC from DO where Cd_DO = @Cd_DO)

		-- CARICA I DATI DA IMPORTARE IN @rl ....................................................................

		-- Tabella temporanea di tutte le Matricole da importare
		declare @rl as table (Id_xMOMatricola int, Cd_xMOMatricola varchar(80), DataOra smalldatetime, Err smallint default 0)

		-- Inserisce tutte le rilevazioni da creare
		insert into @rl (Id_xMOMatricola, Cd_xMOMatricola, DataOra)
		select 
			Id_xMOMatricola, Cd_xMOMatricola, DataOra 
		from
			xMOMatricola 
		where
				Stato = 0 
			And	Cd_xMOLinea = @Cd_xMOLinea

		-- VERIFICHE ..........................................................................................

		-- Verifica che le Matricole che non siano presenti in un documento di carico
		declare @FM_Id_xMOMatricola int
		declare @FM_Cd_xMOMatricola varchar(80)
		declare @FM_DataOra smalldatetime

		DECLARE cur_mat CURSOR FOR Select Id_xMOMatricola, Cd_xMOMatricola, DataOra from @rl

		OPEN cur_mat  
		FETCH NEXT FROM cur_mat INTO @FM_Id_xMOMatricola , @FM_Cd_xMOMatricola, @FM_DataOra

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			if exists(select * from DoRig where Cd_DO = @Cd_DO And DataDoc >= @FM_DataOra And cast(Matricole as varchar(max)) like '%"' + @FM_Cd_xMOMatricola + '"%') 
				update @rl set Err = -10 where Id_xMOMatricola = @FM_Id_xMOMatricola

		FETCH NEXT FROM cur_mat INTO @FM_Id_xMOMatricola , @FM_Cd_xMOMatricola, @FM_DataOra
		END  

		CLOSE cur_mat  
		DEALLOCATE cur_mat 

		-- CARICA I PARAMETRI PER LA GENERAZIONE DEL DOCUMENTO ................................................
		
		-- Carica il magazzino associato alla linea
		declare @xMOLinea_Cd_MG char(5)
		set @xMOLinea_Cd_MG = (select Cd_MG From xMOLinea Where Cd_xMOLinea = @Cd_xMOLinea)

		-- Carica i default di testa del documento
		declare @Cd_MG_P char(5)
		declare @Cd_MG_A char(5)
		declare @Cd_MGCausale char(3)
	
		select @Cd_MG_P	= MGCausale_Cd_MG_P, @Cd_MG_A = MGCausale_Cd_MG_A, @Cd_MGCausale = Cd_MGCausale from dbo.DOTes_Defaults(@Cd_DO, @Cd_CF, getdate())

		-- CARICA I DEFAULT DELLA CAUSALE DI MAGAZZINO
		declare @MagPFlag bit
		declare @MagaFlag bit

		Select @MagPFlag = MagPFlag, @MagaFlag = MagaFlag from MGCausale where Cd_MGCausale = @Cd_MGCausale

		-- Se il magazzino di parteza è abilitato (dalla causale) ma nullo (nei DOTes_Defaults del documento) lo imposta uguale a quello della linea
		if (@MagPFlag = 1 And isnull(@Cd_MG_P, '') = '') set @Cd_MG_P = @xMOLinea_Cd_MG
		-- Se il magazzino di arrivo è abilitato (dalla causale) ma nullo (nei DOTes_Defaults del documento) lo imposta uguale a quello della linea
		if (@MagAFlag = 1 And isnull(@Cd_MG_A, '') = '') set @Cd_MG_A = @xMOLinea_Cd_MG

		-- GENERAZIONE DELLE TABELLE CONTENENTI I DATI DA IMPORTARE ...........................................

		-- drop table #DoRig
		-- Tabella temporanea righe documento
		CREATE TABLE #DORig( 
			Riga				int IDENTITY (1, 1)		not null
			, RigaPadre			int							null	-- Utile per la generazione delle righe P/C
			, TipoPC			char(1)					not null	-- Gestiamo solo i P/C
			, Cd_AR				varchar(20)				not null
			, Cd_MG_P			char(5)						null
			, Cd_MG_A			char(5)						null
			, Descrizione		varchar(80)					null
			, Cd_ARLotto		VARCHAR(20)					null
			, Matricole			xml							null	
			, Qta				numeric(18, 8)			not null
			, Cd_ARMisura		char(2)					not null
			, FattoreToUM1		numeric(18,8)			not null
			, DataConsegna		smalldatetime				null
			, Id_DORig_Evade	int							null
			-- , Cd_Aliquota		VARCHAR(3)
			-- , Cd_CGConto		VARCHAR(12)
			-- , Prezzo			NUMERIC(18, 6)
			-- , PrezzoAddizionale NUMERIC(18, 6)
			-- , Sconto			VARCHAR(20)
			-- , ScontoAddizionale VARCHAR(20)
			-- , Provvigione1		VARCHAR(20)
			-- , Provvigione2		VARCHAR(20)
		)

		-- Aggiunge le righe P
		insert into #DORig (TipoPC, Cd_AR, Descrizione, Cd_MG_P, Cd_MG_A, Cd_ARLotto, Matricole, Qta, Cd_ARMisura, FattoreToUM1, DataConsegna)
		select
			TipoPC				= 'P' 
			, Cd_AR				= l.Cd_AR
			, Descrizione 		= a.Descrizione
			, Cd_MG_P			= @Cd_MG_P
			, Cd_MG_A			= @Cd_MG_A
			, Cd_ARLotto		= l.Cd_ARLotto
			, Matricole			= case when isnull(l.Matricole, '') <> '' then '<rows>' + l.Matricole + '</rows>' else null end
			-- Quantità Fissa pari al numero di matricole importate
			, Qta				= l.Qta -- Per ogni matricola è 1 QTA CAST(1 as numeric(18, 8)) 
			-- Unità di misura di default
			, Cd_ARMisura		= @Cd_ARMisura
			, FattoreToUM1		= isnull((select UMFatt from ARARMisura where Cd_AR = l.Cd_AR And Cd_ARMisura = @Cd_ARMisura), 1)
			, DataConsegna 		= CAST(GETDATE() as smalldatetime)
		from 
			-- Matricole da importare (Stato = 0)
			(
				-- raggruppa le matricole per articolo/lotto/linea
				select 
					Cd_AR
					, Cd_ARLotto
					, Cd_xMOLinea
					, Qta
					, Matricole = (select "@matricola" = upper(rtrim(ltrim(Cd_xMOMatricola))) FROM xMOMatricola Where Stato = 0 And Cd_AR = m.Cd_AR And Cd_ARLotto = m.Cd_ARLotto And Cd_xMOLinea = m.Cd_xMOLinea FOR XML PATH ('row')) 
				from (
					-- Seleziona gli articoli RAGGRUPPATI da importare (preparati in @rl)
					select 
						Cd_AR
						, Cd_ARLotto
						, Cd_xMOLinea
						, Qta			= COUNT(*)
					from 
						xMOMatricola 
					where 
						Id_xMOMatricola  in (select Id_xMOMatricola from @rl where Err = 0) -- 0 = Nessun Errore
					group by 
						Cd_AR
						, Cd_ARLotto
						, Cd_xMOLinea
				) m
			) l
			inner join Ar 			a	on l.Cd_AR = a.Cd_AR
		order by 
			l.Cd_AR
			, l.Cd_ARLotto

		-- Se esistono P senza Matricola fallisce il batch		
		if exists(select * from #DORig where Matricole is null) begin
			set @r = 0; set @m = 'Errore in fase di caricamento dell Matricole per i Prodotti da importare.'; goto exitsp;
		end

		/* Dichiarazione variabili identificativi per relazionare testa, righe, matricole */
		declare @Id_DOTes_New int

		/* Inizio inserimento documento */
		begin transaction tran_GeneraDoc

			-- Se la gestione P/C è attiva per il documento genera i C
			if (@CreaConPC = 1) begin

				-- CARICA I C DALLA DISTINTA BASE ......................................................................
				insert into #DORig (RigaPadre, TipoPC, Cd_AR, Descrizione, Cd_MG_P, Cd_MG_A, Cd_ARLotto, Matricole, Qta, Cd_ARMisura, FattoreToUM1, DataConsegna)
				select 
					RigaPadre			= r.Riga
					, TipoPC			= 'C'
					, Cd_AR				= m.Cd_AR
					, Descrizione 		= a.Descrizione
					, Cd_MG_P			= @Cd_MG_P
					, Cd_MG_A			= @Cd_MG_A
					, Cd_ARLotto		= null -- I lotti vengono gestiti successivamente
					, Matricole			= null -- Le matricole non sono gestite nei C
										-- (r.Qta * r.FattoreToUM1 = Quantità nell'unità di misura principale del padre) * (m.ConsumoUM1 = Consumo del componente nell'unità di misura principale del padre)
					, Qta				= r.Qta * r.FattoreToUM1 * m.ConsumoUM1
										-- Unità di misura di default del componente (altrimeno non potremmo consumare il lotto)
					, Cd_ARMisura		= upper(aum.Cd_ARMisura)
										-- Fattore dell'unità di misura di default del componente (direi 1!)
					, FattoreToUM1		= aum.UMFatt
					, DataConsegna 		= CAST(GETDATE() as smalldatetime)
				from 
					#DORig						r
						inner join DB			d	on r.Cd_AR = d.Cd_AR
						inner join DBMateriale	m	on d.Id_DB = m.Id_DB
						inner join Ar 			a	on m.Cd_AR = a.Cd_AR
						inner join ARARMisura 	aum	on a.Cd_AR = aum.Cd_AR And aum.DefaultMisura = 1
				where
					-- Fine validità nulla o superiore ad ora
					m.FineValidita is null or m.FineValidita > getdate()
				-- ### devo usare dbo.DBEsplodiAll per gestire anche i fantasmi!!!

				-- CARICA I DATI DA IMPORTARE IN @c ....................................................................
				declare @c as table (Id_xMOConsumo int, Cd_AR varchar(20), Cd_ARLotto varchar(20), Err smallint default 0)

				-- CARICO C CON LOTTO ........................................................................
				declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

				-- Aggiorna le giacenze dei lotti 
				update xMOConsumo set
					Stato = case 
								when d.Cd_AR is null then 
									-10 -- l'articolo e il lotto non esitono
								else
									case when d.Quantita > 0 then 
										-- l'articolo e il lotto possiedono giacenza
										0
									else	
										-- l'articolo e il lotto NON possiedono giacenza
										1 
									end
								end
				from
					xMOConsumo												c 
						left join MGGiacEx(@Cd_MGEsercizio)	d	on c.Cd_AR = d.Cd_AR And c.Cd_ARLotto = d.Cd_ARLotto
				where
					c.Stato = 0


				-- GENERAZIONE LOTTI ......................................................................
				-- ATTENZIONE!!! ORA I LOTTI VENGONO GENERATI DA TRIGGER!!!
				-- ......................................................................
				-- Creazione dei Lotti del Padre 
				--insert into ARLotto (Cd_ARLotto, Cd_AR, Descrizione, Note_ARLotto)		-- , DataScadenza
				--select 
				--	Cd_ARLotto		= r.Cd_ARLotto
				--	, Cd_AR			= r.Cd_AR
				--	, Descrizione	= 'Lotto ' + r.Cd_ARLotto
				--	-- , DataScadenza	=  -- < Da gestire
				--	, Note_ARLotto	= 'Import da MOOVI'
				--from 
				--	#DoRig r
				--		left join ARLotto arl on r.Cd_ARLotto = arl.Cd_ARLotto And r.Cd_AR = arl.Cd_AR
				--where 
				--	-- Lotto del padre
				--		r.TipoPC = 'P'
				--	-- Il lotto delle Matricole NON DEVE essere nullo
				--	And	Not r.Cd_ARLotto is null
				--	-- Il lotto NON DEVE essere già definito in anagrafica
				--	And arl.Cd_ARLotto is null
				--group by 
				--	r.Cd_ARLotto
				--	, r.Cd_AR

				-- CARICO I LOTTI UTILIZZABILI .......................................................................
				declare @lt as table (Cd_AR varchar(20), Cd_ARLotto varchar(20), DataScadenza smalldatetime, Quantita numeric(18, 8), QtaResidua numeric(18, 8))

				insert into @lt (Cd_AR, Cd_ARLotto, DataScadenza, Quantita, QtaResidua)
				select 
					g.Cd_AR
					, g.Cd_ARLotto
					, l.DataScadenza
					, g.Quantita	-- ATTENZIONE La quantità è espressa nell'unità di misura principale !!
					, g.Quantita
				from 
					-- Tutti i lotti di xMOConsumo commegati alla giacenza danno una disponibilità di consumo
					xMOConsumo											c
					inner join MGGiacEx(@Cd_MGEsercizio)	g	on c.Cd_AR = g.Cd_AR And c.Cd_ARLotto = g.Cd_ARLotto
						inner join (
							Select distinct 
								Cd_AR
							from 
								#DORig						
							where
								TipoPC = 'C'
							)											r	on g.Cd_AR = r.Cd_AR 
						inner join ARLotto								l	on g.Cd_AR = l.Cd_AR And g.Cd_ARLotto = l.Cd_ARLotto
				where
					-- Lotto "consumato" che possiede giacenza (stato = 0)
						c.Stato = 0
					-- Magazzino di prelievo dei lotti di avvio consumo
					And g.Cd_MG = @Cd_MG
					-- Presenza del lotto
					And	not g.Cd_ARLotto is null
					-- Esistenza della quantità del lotto
					And g.Quantita > 0
		

				-- SCAN (!!) ESPLOSIONE LOTTI ........................................................................
				declare @al_Riga		int					-- Riga corrente 
				declare @al_Cd_AR		varchar(20)			-- Articolo C
				declare @al_Qta			numeric(18, 8)		-- Quantità dell'articolo C
		
				declare @Cd_ARLotto		varchar(20)			-- Lotto trovato
				declare @QtaArLotto		numeric(18, 8)		-- Quantità del lotto ricavato da MGGiac
				declare @QtaResidua		numeric(18, 8)		-- Quantità residua della nuova riga 
				declare @QtaAssegnata	numeric(18, 8)		-- Quantità assegnata della nuova riga 
				declare @NumRow			int					-- @NumRow = 1 indica se è la prima assegnazione

				-- Tabella temporanea per l'aggiornamento dei lotti nel cursore #DocRig
				declare @trl as table (Riga int, Cd_ARLotto varchar(20), Quantita numeric(18, 8), ForUpdate bit)

				-- Seleziona tutti i componenti esplosi per determinarne il lotto 
				declare c_DORigC cursor fast_forward for (select Riga, Cd_AR, Qta from #DORig where TipoPC = 'C')	
		
				--- select * from #DORig

				-- PER IL DEBUG
				--declare @x xml

				-- PER IL DEBUG
				--set @x = (select Riga, Cd_AR, Qta from #DORig where TipoPC = 'C' for xml path ('row'))			
				--set @x = (select Riga, Cd_AR, Qta from #DORig for xml path ('row'))			

				open c_DORigC 
				fetch next from c_DORigC into @al_Riga, @al_Cd_AR, @al_Qta 

				while @@FETCH_STATUS = 0  
				begin  
			
					set @NumRow			= 0
					set @QtaAssegnata	= 0
					set @QtaResidua		= @al_Qta

					while (@QtaResidua > 0)
					begin

						set @NumRow = @NumRow + 1

						-- PER IL DEBUG
						--set @x = (select * from @lt where Cd_AR	= @al_Cd_AR for xml path ('row'))	
				
						-- Reset delle variabili perché TOP 1 WITH TIES se non resitituisce un valore valido e di conseguenza non assegna i valori alle varibili!!!!
						set @Cd_ARLotto = null; set @QtaArLotto = 0;

						-- Seleziona il lotto e la quanità assegnabile per l'articolo C dai residui dei lotti
						select top 1 with ties 
							-- Lotto in esame
							@Cd_ARLotto = Cd_ARLotto
							-- La quantità assegnabile è pari a quella residua
							, @QtaArLotto = ISNULL(QtaResidua, 0) 
						from 
							@lt 
						where 
								-- Articolo in esame
								Cd_AR = @al_Cd_AR 
								-- QtaResidua = Quantita - QtaAssegnata: esiste quantità assegnabile
							And QtaResidua > 0
						order by 
							-- Quello con data scadenza più vicina
							row_number() over(order by DataScadenza)

						-- Verifica la presenza del lotto
						if (isnull(@Cd_ARLotto, '') <> '' And (@QtaArLotto > 0)) begin 

							-- Verifica se la quantità del lotto è sufficiente alla riga
							--		Se esiste quantità di un lotto utile
							--   E	Se la quantità del lotto utile è maggiore di quella residua la assegna
							if (@QtaArLotto > @QtaResidua) begin

								-- Riga con Quantità del lotto sufficente: memorizza la quantità residua 
								set @QtaAssegnata	= @QtaResidua

							end else begin

								-- Riga con Quantità del lotto NON sufficente: memorizza la quantità totale del lotto 
								set @QtaAssegnata	= @QtaArLotto

							end

							-- Abbassa il residuo del lotto selezionato
							update @lt set
								QtaResidua = QtaResidua - @QtaAssegnata
							where 
									Cd_AR		= @al_Cd_AR 
								And	Cd_ARLotto	= @Cd_ARLotto
						
							-- PER IL DEBUG
							--set @x = (select * from @lt where Cd_AR	= @al_Cd_AR And	Cd_ARLotto	= @Cd_ARLotto for xml path ('row'))			
								
						end else begin

							-- Non esiste lotto con quantità da assegnare: la riga C sarà senza lotto
							set @QtaAssegnata	= @QtaResidua

						end

						-- Aggiunge la riga nella tabella temporanea (@NumRow = 1 è un update)
						insert into @trl (Riga, Cd_ARLotto, Quantita, ForUpdate)
						values (@al_Riga, @Cd_ARLotto, @QtaAssegnata, cast(case when @NumRow = 1 then 1 else 0 end as bit))
				
						-- Riassegna la quantità residua
						set @QtaResidua	= @QtaResidua - @QtaAssegnata

					end

					fetch next from c_DORigC into @al_Riga, @al_Cd_AR, @al_Qta 
				end

				close c_DORigC
				deallocate c_DORigC

				-- INSERISCO le nuove righe con (o senza) lotto in base alle ripartizioni per le righe C 
				insert into #DORig (RigaPadre, TipoPC, Cd_AR, Descrizione, Cd_MG_P, Cd_MG_A, Cd_ARLotto, Matricole, Qta, Cd_ARMisura, FattoreToUM1, DataConsegna)
				select 
					RigaPadre			= r.RigaPadre
					, TipoPC			= r.TipoPC
					, Cd_AR				= r.Cd_AR
					, Descrizione 		= r.Descrizione
					, Cd_MG_P			= r.Cd_MG_P
					, Cd_MG_A			= r.Cd_MG_A
					, Cd_ARLotto		= trl.Cd_ARLotto
					, Matricole			= null -- Le matricole non sono gestite nei C
					, Qta				= trl.Quantita
					, Cd_ARMisura		= upper(r.Cd_ARMisura)
					, FattoreToUM1		= r.FattoreToUM1
					, DataConsegna 		= r.DataConsegna
				from 
					#DORig						r
						inner join @trl			trl		on r.Riga = trl.Riga
				where
					-- Solo righe da aggiungere
					trl.ForUpdate = 0

				-- AGGIORNO le righe con (o senza) lotto in base alle ripartizioni per le righe C 
				update #DORig set
					Cd_ARLotto			= trl.Cd_ARLotto
					, Qta				= trl.Quantita
				from 
					#DORig						r
						inner join @trl			trl		on r.Riga = trl.Riga
				where
					-- Solo righe da aggiornare
					trl.ForUpdate = 1
			end

			-- select * from #DORig

			-- GENERAZIONE doc ........................................................................
			
			-- Faccio il documento se esistono righe da generare
			if exists(select * from #DORig where TipoPC = 'P') begin

				exec asp_DO_Begin 0, 1

				/* Inserimento della testa */
				insert into DOTes(Cd_DO, Cd_CF, DataDoc, xCd_xMOLinea) 
				Values (@Cd_DO, @Cd_CF, GETDATE(), @Cd_xMOLinea) 

				set @Id_DOTes_New = SCOPE_IDENTITY()
				if (@@ROWCOUNT < 1) begin
					set @r = -50; set @m = 'Inserimento testa documento fallito!!'; goto exitsp;
				end

				/* Aggiornamento dei defaults di riga per le righe aggiunte */
				--UPDATE #DoRig SET 
				--	Cd_Aliquota       = dbo.xfn_DoRig_Defaults(1, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	Cd_CGConto        = dbo.xfn_DoRig_Defaults(2, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	Prezzo            = dbo.xfn_DoRig_Defaults(3, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	PrezzoAddizionale = dbo.xfn_DoRig_Defaults(4, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	Sconto            = dbo.xfn_DoRig_Defaults(5, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	ScontoAddizionale = dbo.xfn_DoRig_Defaults(6, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	Provvigione1      = dbo.xfn_DoRig_Defaults(7, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL),
				--	Provvigione2      = dbo.xfn_DoRig_Defaults(8, @Id_DoTes_New, GETDATE(), Cd_AR, Qta, NULL, NULL)

				/* Inserimento righe */
				insert into DORig(Id_DOTes, TipoPC, Cd_AR, Descrizione, Cd_MG_P, Cd_MG_A, Cd_ARLotto, Matricole, Qta, Cd_ARMisura, FattoreToUM1, DataConsegna)
				select 
					@Id_DOTes_New
					, case when @CreaConPC = 1 then r.TipoPC else ' ' end -- Se la gestione P/C non è attiva nel documento non vengono generati i C e il padre è scaricato a distinta
					, r.Cd_AR
					, r.Descrizione
					, r.Cd_MG_P
					, r.Cd_MG_A
					, r.Cd_ARLotto
					, r.Matricole
					, r.Qta
					, upper(r.Cd_ARMisura)
					, r.FattoreToUM1
					, r.DataConsegna
				from 
					#DORig r
				Order by
					-- Ordinando per Riga Padre vengono messi vicini gli articoli P/C
					case when r.RigaPadre is null then r.Riga else r.RigaPadre end
					-- Sempre prima i padri P
					, case when r.TipoPC = 'P' then 1 else 2 end
					-- Ordina per articolo
					, r.Cd_AR

				/* Chiusura documento */
				exec @rdoe = asp_DO_End @Id_DOTes_New, 0
			
			end

			-- SALVA LE RILEVAZIONI COME STORICIZZATE O COME ERRATE ..................................................... 
			update xMOMatricola set 
				Id_DORig	= case when rl.Err = 0 then drm.Id_DORig else null end
							-- Stato = 1: Importato; <0: Errore
				, Stato		= case when rl.Err = 0 then 1 else rl.Err end
				, Messaggio = cast(ERROR_MESSAGE() as varchar(max))
			from 
				xMOMatricola					m 
					inner join @rl				rl	on m.Id_xMOMatricola = rl.Id_xMOMatricola
					-- Seleziona tutte le matricole delle teste create
					inner join (select Id_DORig = max(Id_DORig), Matricola FROM DORigMatricola Where Id_DoTes = @Id_DOTes_New group by Matricola) as drm	on rl.Cd_xMOMatricola = drm.Matricola

		if @@TRANCOUNT > 0 commit transaction tran_GeneraDoc

		drop table #DORig

		set @id= @Id_DOTes_New;
		set @r = case when @Id_DOTes_New > 0 then 1 else 0 end;
		
	End try
	Begin catch 
		set @r = case when @rdoe < 0 then @rdoe else abs(ERROR_NUMBER()) * -1 end; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		if @@TRANCOUNT > 0 rollback transaction;
		-- restituisce il risultato dei controlli con una select
		select 
			Result			= @r, 
			Id_xMORL		= @id, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.') + ' [rdoe ' + ltrim(rtrim(str(isnull(@rdoe, -99999)))) + ']'

	return 
end
go

create procedure xmosp_xMORLLast_Del(
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)
	, @Id_xMORL_Del		int		
)
/*ENCRYPTED*/
as begin	
	-- Elimina l'ultima lettura
	declare @r				int				-- risultato della sp
	declare @Id_xMORLRig	int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		declare @Id_xMORLRig_Del int

		-- Seleziona l'ultima riga letta
		set @Id_xMORLRig_Del = (select top 1 Id_xMORLRig from xMORLRig where Id_xMORL = @Id_xMORL_Del order by 1 desc)

		delete from xMORLRig where Id_xMORLRig = @Id_xMORLRig_Del
		set @Id_xMORLRig	= @Id_xMORLRig_Del
		set @r				= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMoRLRig		= @Id_xMORLRig_Del, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')

		return @r
end 
go

create procedure xmosp_xMORLRig_Del(
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)		
	, @Id_xMORLRig_Del	int					
) 
/*ENCRYPTED*/
as begin	

	declare @r				int				-- risultato della sp
	declare @Id_xMORLRig	int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try
		
		declare @Id_xMORL int
		declare @Id_DoRig int
		select 
			@Id_xMORL = Id_xMORl 
			, @Id_DoRig = Id_DoRig
		from 
			xMORLRig
		where 
			id_xMORLRig = @Id_xMORLRig_Del

		declare @Prelievo smallint
		Set @Prelievo = (Select xMOPrelievo From DO where Cd_DO = (Select Cd_DO From xMORL Where Id_xMORL = @Id_xMORL))
		-- Se non c'è prelievo ma è stato passato un Id_DORig lo elimina se presente
		if @Prelievo = 0 And isnull(@Id_DORig, 0) > 0 And exists(select * from xMORLPrelievo Where Id_xMORL = @Id_xMORL And Id_DORig = @Id_DORig) begin
			delete from xMORLPrelievo
			Where Id_xMORL = @Id_xMORL And Id_DORig = @Id_DORig
		end

		delete from xMORLRig where id_xMORLRig = @Id_xMORLRig_Del
		set @Id_xMORLRig	= @Id_xMORLRig_Del
		set @r				= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMoRLRig		= @Id_xMORLRig, 
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')

		return @r
end 
go

-- Esegue i controlli aggiuntivi sulla lettura 
-- risultato della sp: 
--						1 = Tutto Ok; 
--						2 = Intervento dell'operatore; 
--						<0 = ERRORE
create procedure xmosp_xMORLRig_Controlli (
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Id_xMORL				int					--O I campi passati alla funzione sono utili alla validazione --O
	, @Matricola			varchar(80)			--O
	, @Cd_DOSottoCommessa	varchar(20)			--O
	, @Cd_AR				varchar(20)			--O
	, @Cd_ARLotto			varchar(20)			--O
	, @Quantita				numeric(18,8)		--O
	, @Message				varchar(max)		OUT
) 
/*ENCRYPTED*/
as begin

	declare @r				int				
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		-- Verifica SSCC con tutti i controlli
			
		declare @Ctrl		varchar(20)		-- Controllo corrente
		declare @par1		numeric(18,8)	-- Campo per la parametrizzazione del controllo

		-- Recupera i controlli da eseguire dal documento
		declare @c table (Cd_xMOControllo varchar(20), Descrizione varchar(150))
		
		insert into @c
		select Cd_xMOControllo, Descrizione from dbo.xmovs_DOxMOControlli
		where Cd_DO = (Select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)

		-- Verifica controllo (setta @Ctrl_Fail a: 1 = tutto ok; 2 = intervento dell'operatore; 0 = Fallisce i controlli con messaggio noto; <0 = ERRORE sconosciuto
		set @m = '';
		
		-- Standard ............................................................

		-- SCADENZA DEL LOTTO ENTRO I 2 MESI
		set @Ctrl = 'LOT/SCA/ALERT1';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			set @par1 = (select Parametro1 from xMOControllo where Cd_xMOControllo = @Ctrl) 
			if exists(select * from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto And DataScadenza <= GETDATE() + case when Isnull(@par1, 0) = 0 then 60 else @par1 end) begin
				-- Controllo necessita di intervento dell'operatore
				set @m = @m + (select replace(Descrizione, '%1', rtrim(ltrim(str(@par1)))) from @c where Cd_xMOControllo = @Ctrl);
			end
		end
					
		-- PRODOTTO DA 2 GIORNI 
		set @Ctrl = 'LOT/PRO/ALERT1';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			set @par1 = (select Parametro1 from xMOControllo where Cd_xMOControllo = @Ctrl) 
			-- Verificare xMOMAtricola
			if exists(select * from xMOMatricola Where Cd_xMOMatricola = @Matricola And DataOra >= (GETDATE() - Isnull(@par1, 2))) begin
			-- Verifica sui documenti
			--if exists(select * from DORig inner join DORigMatricola on DORig.Id_DORig = DORigMatricola.Id_DORig where DORig.Cd_DO = (select MatCd_DO from xMOImpostazioni) And DORigMatricola.Matricola = @Matricola And DataConsegna >= (GETDATE() - Isnull(@par1, 2))) begin
				-- Controllo necessita di intervento dell'operatore
				set @m = @m + (select replace(Descrizione, '%1', rtrim(ltrim(str(@par1)))) from @c where Cd_xMOControllo = @Ctrl);
			end
		end

		-- MATRICOLA PRESENTE NELLE LETTURE DI UN ALTRO OP
		set @Ctrl = 'MAT/LET/OPE';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			declare @Id_xMORL_Test varchar(20)
			set @Id_xMORL_Test = (select top 1 Id_xMORL from xmorl where Stato = 0 And Id_xMORL in (select Id_xMORL from xMORLRig where xMORLRig.Matricola = @Matricola))
			-- verifico se è stata trovata una testa contenente nelle righe la matricola da verificare
			if IsNull(@Id_xMORL_Test, 0) > 0 begin
				set @m = @m + 'Matricola già esistente nelle letture: ' + dbo.xmofn_xMORL_Info(@Id_xMORL_Test);
				set @r = -880;
				goto exitsp;
			end
		end

		-- MATRICOLA NON DISPONIBILE (GIA' VENDUTA)
		set @Ctrl = 'MAT/DISP/ALERT';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			-- se nella lettura è presente la matricola verifico se è disponibile
			if IsNull(@Matricola, '') <> '' and exists(select * from xMOMatricola where Cd_xMOMatricola = @Matricola and Disattiva = 1) begin
				set @m = @m + + (select Descrizione from @c where Cd_xMOControllo = @Ctrl);
				set @r = -885;
				goto exitsp;
			end
		end

		-- DISPONIBILITA DELLA GIACENZA PER MATRICOLA PER LA QTA DELLE RIGHE DELLA RILEVAZIONE
		set @Ctrl = 'MAT/GIAC/ALERT';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			-- SOLO PER DOCUMENTI CHE SCARICANO LA GIACENZA (2) E ARTICOLI ABILITATI ALLA GIACENZA PER MATRICOLA
			if((select xMOMatGiacTipo from DO where Cd_DO = (select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)) = 2 and (select xMOAbilitaMatGiac from AR where Cd_AR = @Cd_AR) = 1)begin
				-- verifica se la giacenza della matricola è sufficiente per le letture effettuate nella rilevazione
				declare @QtaLetta numeric(18,8) = (select (sum(Quantita) + @Quantita) * FattoreToUM1 from xMORLRIg where Id_xMORL = @Id_xMORL group by FattoreToUM1)
				declare @MatGiac numeric(18,8) = (select Quantita from xMOMatGiac where Matricola = @Matricola and Cd_AR = @Cd_AR and Cd_ARLotto = ISNULL(@Cd_ARLotto, ''))
				if(@QtaLetta > @MatGiac)begin
					set @m = @m + (select Descrizione from @c where Cd_xMOControllo = @Ctrl);
					set @r = -886;
					goto exitsp;
				end
			end
		end

		set @Ctrl = 'COM/PREL/EXISTS';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			if isnull(@Cd_DOSottoCommessa, '') <> '' And not exists(select * from DORig Where Cd_AR = @Cd_AR AND Cd_DOSottoCommessa = @Cd_DOSottoCommessa And Id_DORig in (select Id_DORig from xMORLPrelievo where Id_xMORL = @Id_xMORL)) begin
				-- Sottocommessa per l'articolo corrente non presente nei prelievi.                                                                                                              
				set @m = @m + (select Descrizione from @c where Cd_xMOControllo = @Ctrl) + ' <br/>Per l''articolo [' + @Cd_AR + '] manca la Sottocommessa  [' + ltrim(rtrim(@Cd_DOSottoCommessa)) + ']';
				set @r = -887;
				goto exitsp;
			end
		end

		-- PERSONALIZZATI !!!............................................................

		-- Matricola non presente in documenti che iniziano per 'D'
		set @Ctrl = 'NOC/MAT/DOC/D';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			declare @doc char(3)
			-- Seleziona l'ultimo doc temporalmente dichiarato
			set @doc = (select top 1 Cd_DO from DORig inner join DORigMatricola on DORig.Id_DORig = DORigMatricola.Id_DORig where Matricola = @Matricola order by DataDoc desc);
			--set @doc = (select top 1 Cd_DO from DORig inner join DORigMatricola on DORig.Id_DORig = DORigMatricola.Id_DORig where DORig.Cd_DO like 'D%' And Matricola = @Matricola);
			-- verifica che l'ultimo documento non corrisponda a un D (la matricola risulterebbe venduta): errore!
			if (case when @doc like 'D%' then 1 else 0 end) = 1 begin
				-- Controllo bloccante
				set @m = @m + (select Descrizione + ' [' + @doc + ']' from @c where Cd_xMOControllo = @Ctrl);
				set @r = -888;
				goto exitsp;
			end
		end

		-- SCADENZA DEL LOTTO ENTRO x Giorni dall'anagrafica articolo
		set @Ctrl = 'LOT/SCA/ALERTAR1/G4';
		if exists(select * from @c where Cd_xMOControllo = @Ctrl) begin
			-- Par1 viene recuperato dall'anagrfica articolo
			set @par1 = null
			-- xMaxConsegna
			declare @xMOSearch nvarchar(1000) = 'select @par1=xMaxConsegna from Ar Where Cd_Ar = ''' + @Cd_Ar + ''''
			exec sp_executesql @xMOSearch, N'@par1 numeric(18,8) output', @par1 output;

			if isnull(@par1, 0) > 0 And exists(select * from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto And DataScadenza <= dateadd(MM, case when Isnull(@par1, 0) = 0 then 3 else (@par1) end, GETDATE())) begin
				-- Controllo necessita di intervento dell'operatore
				set @m = @m + (select replace(Descrizione, '%1', rtrim(ltrim(str(@par1)))) from @c where Cd_xMOControllo = @Ctrl);
			end
		end

		-- Tutto Ok se non ci sono messaggi
		set @r = case when isnull(@m, '') = '' then 1 else 2 end

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		set @Message = isnull(@m, 'Controlli effettuati con successo.');
		return @r;
		
end 
go

create procedure xmosp_xMORLPackListRef_Add(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Id_xMORL				int 
	, @PackListRef			varchar(20) 
	, @Cd_xMOUniLog			varchar(20) 
)
/*ENCRYPTED*/
as begin
	declare @r		int				-- risultato della sp
	declare @Id		int				-- identificativo del record aggiunto
	declare @m		varchar(max)	-- Messaggio di errore
	begin try

		-- Controlla i dati
		if (isnull(@Id_xMORL, 0) = 0) begin
			set @r = -1; set @m = 'Identificativo della rilevazione RL errato o mancante!!'; goto exitsp;
		end

		if (isnull(@PackListRef, '') = '') begin
			set @r = -2; set @m = 'Identificativo dell''unità logistica errato o mancante!!'; goto exitsp;
		end

		-- Normalizzo i dati
		if (isnull(@Cd_xMOUniLog, '') = '')	set @Cd_xMOUniLog = null

		declare @PesoTaraMks	numeric(18,4); set  @PesoTaraMks	= 0;
		declare @AltezzaMks		numeric(18,4); set  @AltezzaMks		= 0;
		declare @LunghezzaMks	numeric(18,4); set  @LunghezzaMks	= 0;
		declare @LarghezzaMks	numeric(18,4); set  @LarghezzaMks	= 0;
		
		if (@Cd_xMOUniLog is not null) begin
			select 	
				@PesoTaraMks	= PesoTaraMks	
				, @AltezzaMks	= AltezzaMks		
				, @LunghezzaMks	= LunghezzaMks	
				, @LarghezzaMks	= LarghezzaMks	
			from 
				xMOUniLog
			where
				Cd_xMOUniLog = @Cd_xMOUniLog
		end

		-- Seleziona il possibile id da memorizzare
		set @Id = (select Id_xMORLPackListRef from xMORLPackListRef where Id_xMORL = @Id_xMORL And PackListRef = @PackListRef)
		-- Controllo che non esista il riferimento dell'ul nella testa
		if (isnull(@Id, 0) > 0 ) begin

			-- Salvataggio dell'unità logistica 
			update xMORLPackListRef set 
				Cd_xMOUniLog = @Cd_xMOUniLog
				, PesoTaraMks  = @PesoTaraMks	
				, AltezzaMks   = @AltezzaMks 	
				, LunghezzaMks = @LunghezzaMks	
				, LarghezzaMks = @LarghezzaMks	
			where
					Id_xMORL = @Id_xMORL
				And PackListRef = @PackListRef

		end else begin

			-- Salvataggio della nuova unità logistica 
			insert into xMORLPackListRef (
				Id_xMORL, PackListRef, Cd_xMOUniLog, PesoTaraMks
				, AltezzaMks, LunghezzaMks, LarghezzaMks
			)
			values (
				@Id_xMORL, @PackListRef, @Cd_xMOUniLog, @PesoTaraMks
				, @AltezzaMks, @LunghezzaMks, @LarghezzaMks
				)
			
			set @Id = @@IDENTITY
		end

		set @r = 1
		
	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result					= @r, 
				Id_xMORLPackListRef		= @Id, 
				Messaggio				= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r

end 
go

-- Aggiorna il PackListRef con eventuali pesi e misure 
create procedure xmosp_xMORLPackListRef_Save(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Id_xMORLPackListRef	int 
	, @Cd_xMOUniLog			varchar(20) 
	, @PesoTaraMks			numeric(18,4) 
	, @PesoNettoMks			numeric(18,4) 
	, @PesoLordoMks			numeric(18,4) 
	, @AltezzaMks			numeric(18,4) 
	, @LunghezzaMks			numeric(18,4) 
	, @LarghezzaMks			numeric(18,4) 
)
/*ENCRYPTED*/
as begin
	declare @r		int				-- risultato della sp
	declare @m		varchar(max)	-- Messaggio di errore
	begin try

		-- Controlla i dati
		if (isnull(@Id_xMORLPackListRef, 0) = 0) begin
			set @r = -1; set @m = 'Identificativo della rilevazione RL PackListRef errato o mancante!!'; goto exitsp;
		end

		-- Normalizzo i dati
		if (isnull(@Cd_xMOUniLog, '') = '')	set @Cd_xMOUniLog	= null
		if (isnull(@PesoTaraMks	, 0) = 0)	set @PesoTaraMks	= 0
		if (isnull(@PesoNettoMks, 0) = 0)	set @PesoNettoMks	= 0
		if (isnull(@PesoLordoMks, 0) = 0)	set @PesoLordoMks	= 0
		if (isnull(@AltezzaMks	, 0) = 0)	set @AltezzaMks		= 0
		if (isnull(@LunghezzaMks, 0) = 0)	set @LunghezzaMks	= 0
		if (isnull(@LarghezzaMks, 0) = 0)	set @LarghezzaMks	= 0

		-- Salvataggio dell'unità logistica 
		update xMORLPackListRef set 
			Cd_xMOUniLog = @Cd_xMOUniLog
			, PesoTaraMks  = @PesoTaraMks  
			, PesoNettoMks = @PesoNettoMks
			, PesoLordoMks = @PesoLordoMks
			, AltezzaMks   = @AltezzaMks 
			, LunghezzaMks = @LunghezzaMks
			, LarghezzaMks = @LarghezzaMks
		where
				Id_xMORLPackListRef = @Id_xMORLPackListRef

		set @r = 1
		
	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result					= @r, 
				Id_xMORLPackListRef		= @Id_xMORLPackListRef, 
				Messaggio				= isnull(@m, 'Salvataggio effettuato con successo.')
		return @r

end 
go

create procedure xmosp_xMORLRig_Save(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Id_xMORL				int				
	, @Cd_AR				varchar(20) 	
	, @Cd_MG_P				char(5) 		
	, @Cd_MGUbicazione_P	varchar(20) 	
	, @Cd_MG_A				char(5) 		
	, @Cd_MGUbicazione_A	varchar(20) 	
	, @Cd_ARLotto			varchar(20) 
	, @DataScadenza			smalldatetime
	, @Matricola			varchar(80)
	, @Cd_ARMisura			char(2) 		
	, @UMFatt				numeric(18,8)
	, @Quantita				numeric(18,8)
	, @Barcode				xml 
	, @Cd_DOSottoCommessa	varchar(20)
	, @EseguiControlli		bit	
	, @PackListRef			varchar(20)				-- Codice Unità Logistica
	, @Id_DORig				int
	, @ExtFld				xml	
	-- ###Da completare con l'update di  @Id_xMORLRig	
	, @m					varchar(max) output	
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @Id_xMORLRig	int				-- identificativo del record aggiunto
	--declare @m				varchar(max)	-- Messaggio di errore
	declare @Cd_CF			varchar(20) = 'select Cd_CF from xMORL Where Id_xMORL = @Id_xMORL'
	declare @Cd_DO			char(3)		= (select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)
	-- Controlli pre salvataggio

	-- esistenza magazzino e ubicazione partenza e arrivo esistenti
	-- magazzino partenza
	begin try

		-- Parametri
		declare @ARLottoAuto	tinyint	-- Se 0 non è possibile creare il lotto; > 0 
		
		select @ARLottoAuto = DO.ARLottoAuto from DO where Cd_DO = (select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)

		-- Controlli ...................................................................................................................................................

		-- Esistenza Magazzino di Partenza
		if isnull(@Cd_MG_P, '') <> '' And not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P) begin
			set @r = -10; set @m = 'Codice magazzino ' + @Cd_MG_P + ' errato!!'; goto exitsp;
		end

		-- Obbligatorietà dell'ubicazione per magazzino di partenza
		if isnull(@Cd_MGUbicazione_P, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_P and MG_UbicazioneObbligatoria = 1) begin
			set @r = -15; set @m= 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		end
		
		-- Verifica esistenza ubicazione del magazzino partenza
		if isnull(@Cd_MGUbicazione_P, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_P And Cd_MGUbicazione = @Cd_MGUbicazione_P) begin
			set @r = -18; set @m= 'Codice ubicazione ' + @Cd_MGUbicazione_P + ' del magazzino partenza ' + @Cd_MG_P + ' errato!!'; goto exitsp;
		end

		-- Esistenza Magazzino di Arrivo
		if isnull(@Cd_MG_A, '') <> '' And not exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A) begin
			set @r = -20; set @m = 'Codice magazzino ' + @Cd_MG_A + ' errato!!'; goto exitsp;
		end

		-- Obbligatorietà dell'ubicazione per magazzino di arrivo
		if isnull(@Cd_MGUbicazione_A, '') = '' And exists(select * from xmofn_MG(@Terminale, @Cd_Operatore, null) where Cd_MG = @Cd_MG_A and MG_UbicazioneObbligatoria = 1) begin
			set @r = -25; set @m= 'Codice ubicazione magazzino obbligatorio!!'; goto exitsp;
		end
		
		-- Verifica esistenza ubicazione del magazzino di arrivo
		if isnull(@Cd_MGUbicazione_A, '') <> '' And not exists (select * from MGUbicazione where Cd_MG = @Cd_MG_A And Cd_MGUbicazione = @Cd_MGUbicazione_A) begin
			set @r = -28; set @m= 'Codice ubicazione ' + @Cd_MGUbicazione_A + ' del magazzino arrivo' + @Cd_MG_A + ' errato!!'; goto exitsp;
		end
		
		-- Verifica che esista un prelievo e non sono ammessi i fuorilista: il resulset è dei soli articoli del prelievo
		Declare @Prelievo	bit
		Declare @Fuorilista bit

		Set @Prelievo	= (case when exists(Select * From xMORLPrelievo Where Id_xMORL = @Id_xMORL) then 1 else 0 end)
		Set @Fuorilista = (Select xMOFuorilista From DO where Cd_DO = (Select Cd_DO From xMORL Where Id_xMORL = @Id_xMORL))

		-- Se non c'è prelievo ma è stato passato un Id_DORig lo aggiunge se non presente
		if isnull(@Id_DORig, 0) > 0 And not exists(select * from xMORLPrelievo Where Id_xMORL = @Id_xMORL And Id_DORig = @Id_DORig) begin
			insert into xMORLPrelievo (Id_DOTes, Id_DORig, Id_xMORL)
			select Id_DOTes, Id_DORig, @Id_xMORL
			from DoRig
			Where Id_DORig = @Id_DORig
		end

		-- Per la gestione degli alias e dei codici C/F l'articolo va sempre convertito
		set @Cd_AR = (select dbo.xmofn_Get_AR_From_AAA(@Cd_AR, @Cd_CF))

		if isnull(@Cd_AR, '') = '' Or not exists(select * from xmofn_ARValidate(@Terminale, @Cd_Operatore, @Id_xMORL, null) where Cd_AR = @Cd_AR) begin
			set @r = -30; set @m= 'Codice articolo ' + isnull(@Cd_AR, '') + ' errato o mancante' + case when @Fuorilista = 0 then ' nei prelievi' end + '!!'; goto exitsp;
		end

		-- Esistenza lotto (se il doc li può creare non verifica il lotto)
		if (@ARLottoAuto = 0) And isnull(@Cd_ARLotto, '') <> '' begin
			if not exists(select * from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto) begin
				set @r = -40; set @m= 'Codice lotto ' + @Cd_ARLotto + ' dell''articolo ' + @Cd_AR + ' errato!!'; goto exitsp;
			end
		end

		-- Il lotto è presente: verifica del blocco del lotto per moovi
		if isnull(@Cd_ARLotto, '') <> '' begin
			-- Esiste il lotto come bloccato
			if exists(select * from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto And xMOBlocco = 1) begin
				declare @Note_ARLotto varchar(100) -- Blocco le note a 100 caratteri
				set @Note_ARLotto = (select cast(ltrim(Note_ARLotto) as varchar(100)) from ARLotto where Cd_AR = @Cd_AR And Cd_ARLotto = @Cd_ARLotto And xMOBlocco = 1)
				set @r = -42; set @m = 'Codice lotto bloccato!! ' + isnull(@Note_ARLotto, ''); goto exitsp;
			end
		end

		-- La sottocommessa deve esistere
		if isnull(@Cd_DOSottoCommessa, '') <> '' And not exists(select * from DOSottoCommessa where Cd_DOSottoCommessa = @Cd_DOSottoCommessa)  begin
			set @r = -45; set @m = 'Commessa ' + isnull(@Cd_DOSottoCommessa, '') + ' errata o inesiste!!'; goto exitsp;
		end

		if isnull(@Cd_ARMisura, '') <> '' And not exists(select * from ARARMisura where Cd_AR = @Cd_AR ) begin
			set @r = -50; set @m= 'Codice unità di misura ' + @Cd_ARMisura + ' per l"articolo' + @Cd_AR + '  errato!!'; goto exitsp;
		end
		
		-- IL CONTROLLO SULLA PRESENZA DELLA MATRICOLA IN ALTRE LETTURE VIENE EFFTTUATO SOLO PER DOCUMENTI CHE NON SCARICANO 
		-- LA GIACENZA DELLA MATRICOLA (2) E ARTICOLI NON ABILITATI ALLA GIACENZA PER MATRICOLA
		-- and (select xMOAbilitaMatGiac from AR where Cd_AR = @Cd_AR) = 0
		if((select xMOMatGiacTipo from DO where Cd_DO = (select Cd_DO from xMORL where Id_xMORL = @Id_xMORL)) <> 2)begin
			-- Verifico che se la matricola non è null non sia già stata letta
			if ISNULL(@Matricola, '') <> '' and exists (select Matricola from xMORLRig where Matricola = @Matricola and Id_xMORL = @Id_xMORL) begin
				set @r = -55; set @m = 'La matricola è già presente in una lettura'; goto exitsp;
			end
		end

		-- Ricava il fattore di conversione dall'um dell'articolo
		declare @FattoreToUM1	numeric(18,8)	-- Contiene fattore di unita di misura
		-- Fattore di conversione passato dal client
		-- Se vuoto lo recupera dal quello dell'UM
		set @FattoreToUM1 = @UMFatt
		if isnull(@FattoreToUM1, 0) = 0 begin
			select 
				@FattoreToUM1 = UMFatt
			from 
				ARARMisura 
			where 
					Cd_AR		= @Cd_AR 
				And Cd_ARMisura = @Cd_ARMisura 
		end

		-- Verifica se convertire la letture nell UM di prelievo 
		if isnull((select xMOUmConverti from DO where Cd_DO = @Cd_DO), 0) = 1 begin 
			declare @Cd_ARMisuraPrelievo char(2)
			declare @FattoreToUMPrelievo numeric(18,8)

			-- imposto il fatto a zero in modo che posso testarlo per verificarne la conversione
			set @FattoreToUMPrelievo = 0

			-- Se utilizziamo il prelievo della riga va verificato direttamente su quello e non per articolo+um
			if (isnull(@Id_DORig, 0) > 0) begin
				
				-- Recupero i dati del prelievo
				select @Cd_ARMisuraPrelievo = Cd_ARMisura, @FattoreToUMPrelievo = FattoreToUM1 from DORig Where Id_DORig = @Id_DORig

			end else begin

				-- Verifico che l'um passata al salvataggio sia diversa dal prelievo (deve essere quindi convertita) 
				-- e che nel prelievo ve ne sia una soltanto (altrimenti non saprei quale prendere)
				if -- Unità di misura NON presente nei prelievi
					not exists(select * from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And Cd_AR = @Cd_AR And Cd_ARMisura = @Cd_ARMisura)
					-- Presenza di una unità di misura univoca nei prelievi
					And 1 = (select COUNT(*) from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And Cd_AR = @Cd_AR And Cd_ARMisura <> @Cd_ARMisura) begin

					-- Selezione del fattore di conversione dell'unità di misura del prelievo
					select top 1 @Cd_ARMisuraPrelievo = DoRig.Cd_ARMisura, @FattoreToUMPrelievo = DoRig.FattoreToUM1 
					from
						DoRig inner join xMORLPrelievo on DoRig.Id_DORig = xMORLPrelievo.Id_DORig
					where	
							xMORLPrelievo.Id_xMORL = @Id_xMORL
						And DORig.Cd_AR = @Cd_AR 
						And Cd_ARMisura <> @Cd_ARMisura 
					order by 
						-- Da priorità alle righe con stesso lotto
						case when isnull(DORig.Cd_ARLotto, '') = isnull(@Cd_ARLotto, '') then 0 else 1 end

					-- RIMODULATO DALLE RIGHE E PRESO DIRETTAMENTE DAL PRELIEVO
					-- from 
					-- 	dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) 
					-- where Prelievo = 1 And FuoriLista = 0 And Cd_AR = @Cd_AR And Cd_ARMisura <> @Cd_ARMisura 

					-- Ricalcola quantità rispetto um
					set @Quantita = @Quantita * @FattoreToUM1 / @FattoreToUMPrelievo
					-- Nuova unità di misura
					set @Cd_ARMisura = @Cd_ARMisuraPrelievo
					-- Nuovo fattore conversione
					set @FattoreToUM1 = @FattoreToUMPrelievo

				end

			end

			-- Verifico che il fattore sia valorizzato e che l'um passata al salvataggio sia diversa dal prelievo (deve essere quindi convertita) 
			if (isnull(@Cd_ARMisura, '') <> isnull(@Cd_ARMisuraPrelievo, '') And @FattoreToUMPrelievo > 0) begin
				-- Converto l'UM in quella del prelievo
				-- Ricalcola quantità rispetto um
				set @Quantita = @Quantita * @FattoreToUM1 / @FattoreToUMPrelievo
				-- Nuova unità di misura
				set @Cd_ARMisura = @Cd_ARMisuraPrelievo
				-- Nuovo fattore conversione
				set @FattoreToUM1 = @FattoreToUMPrelievo
			end

		end


		if @Prelievo = 1 And @Fuorilista = 0 begin
			-- Verifica che l'unità di misura letta sia presente nel prelievo!! Altrimenti è come se inserissi un fuorilista
			if not exists(select * from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And Cd_AR = @Cd_AR And Cd_ARMisura = @Cd_ARMisura) begin
				set @r = -58; set @m= 'Attenzione: i fuorilista non sono ammessi e vanno specificate solo le unità di misura coerenti con il prelievo!!'; goto exitsp;
			end
		end

		-- Verifica il fattore di conversione
		if isnull(@FattoreToUM1, 0) = 0  begin
			set @r = -60; set @m= 'Fattore di conversione errato!!'; goto exitsp;
		end

		if @Prelievo = 1 And @Fuorilista = 0 begin
			-- Se esite un prelievo e non sono ammessi i fuorilista verifico che la quantità letta sia minore/uguale a quella residua
			Declare @QtaResidua numeric(18,8)
			-- Ricava la quantità residua nell'unità di misura della rilevazione
			set @QtaResidua = (select sum(QtaResidua) from dbo.xmofn_xMORLRig_AR(@Terminale, @Cd_Operatore, @Id_xMORL) where Prelievo = 1 And FuoriLista = 0 And Cd_AR = @Cd_AR And Cd_ARMisura = @Cd_ARMisura)
			-- Verifica che la quantità letta nell'um principale sia minore/uguale a quella residua
			if @Quantita > @QtaResidua begin
				set @r = -70; set @m= 'La quantità letta ' + ltrim(str(@Quantita)) + ' ' + @Cd_ARMisura + ' è maggiore di quella residua [' + ltrim(str(@QtaResidua)) + ' ' + @Cd_ARMisura + ']!!'; goto exitsp;
			end
		end
		
		if ISNULL(@Cd_ARLotto, '') = ''						set @Cd_ARLotto = null;
		if ISNULL(@DataScadenza, '') = ''					set @DataScadenza = null;
		if ISNULL(@Cd_MG_P, '') = ''						set @Cd_MG_P = null;
		if ISNULL(@Cd_MGUbicazione_P, '') = ''				set @Cd_MGUbicazione_P = null;
		if ISNULL(@Cd_MG_A, '') = ''						set @Cd_MG_A = null;
		if ISNULL(@Cd_MGUbicazione_A, '') = ''				set @Cd_MGUbicazione_A = null;
		if ISNULL(@Matricola, '') = ''						set @Matricola = null;
		if ISNULL(cast(@Barcode as varchar(max)), '') = ''	set @Barcode = null;
		if ISNULL(@Cd_DOSottoCommessa, '') = ''				set @Cd_DOSottoCommessa = null;
		if ISNULL(@PackListRef, '') = ''					set @PackListRef = null;

		-- CONTROLLI AGGIUNTIVI ........................................................................................................................
		if (isnull(@EseguiControlli, 0) = 1) begin

			-- Esegue i controlli aggiuntivi sulla lettura
			declare @rc int, @CtrlMsg varchar(max)
			execute @rc = dbo.xmosp_xMORLRig_Controlli @Terminale, @Cd_Operatore, @Id_xMORL, @Matricola, @Cd_DOSottoCommessa, @Cd_AR, @Cd_ARLotto, @Quantita, @CtrlMsg OUTPUT

			-- Verifica dei controlli del versamento
			if (@rc <> 1) begin
				if (@rc = 2) begin
					-- La lettura necessita di conferma operatore lato client: 
					-- RESTITUISCE (2) come risultato e la messaggistaca appropriata
					select @r = @rc, @m = @CtrlMsg; goto exitsp;
				end
				if (@rc < 1) begin
					-- La lettura è fallita dai controlli operatore: 
					-- RESTITUISCE (<0) come risultato e l'errore 
					select @r = @rc, @m = @CtrlMsg; goto exitsp;
				end
			end
		end
		

		-- SALVATAGGIO ..................................................................................................................................
		-- Inserimento della lettura
		insert into xMORLRig (Id_xMORL, Cd_AR, Cd_MG_P, Cd_MGUbicazione_P	
								, Cd_MG_A, Cd_MGUbicazione_A, Cd_ARLotto, DataScadenza
								, Matricola
								, Cd_ARMisura, FattoreToUM1, Quantita, DataOra
								, Barcode, Terminale, Cd_Operatore, Cd_DOSottoCommessa
								, Id_DORig, ExtFld)
		values (
				@Id_xMORL			
				, @Cd_AR				
				, @Cd_MG_P			
				, @Cd_MGUbicazione_P	
				, @Cd_MG_A			
				, @Cd_MGUbicazione_A	
				, @Cd_ARLotto
				, @DataScadenza	
				, @Matricola		
				, @Cd_ARMisura		
				, @FattoreToUM1		
				, @Quantita			
				, getdate()			
				, @Barcode			
				, @Terminale			
				, @Cd_Operatore		
				, @Cd_DOSottoCommessa
				, case when isnull(@Id_DORig, 0) > 0 then @Id_DORig else null end
				, @ExtFld
			)

		set @r = 1
		set @Id_xMORLRig = @@IDENTITY
			
		if @Id_xMORLRig > 0 And @PackListRef is not null begin
			-- Creazione dettaglio Packing
			insert into xMORLRigPackList (Id_xMORLRig, PackListRef, Qta)
			values (@Id_xMORLRig, @PackListRef, @Quantita)
		end
	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMoRLRig		= @Id_xMORLRig, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

create procedure xmosp_xMOIN_Make_MGMov(
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)
	, @Id_xMOIN			int				-- Id testa IN da salvare
	, @INRig_AllOut		bit				-- Vero smarca tutte le righe come validate
	, @IN_Chiudi		bit				-- Vero chiude la testa dell'inventario
	, @m				varchar(max)	output
)
/*ENCRYPTED*/
as begin	
	-- Elimina l'ultima lettura
	declare @r				int				-- risultato della sp
	declare @Id_MgMovInt	int				-- identificativo del record aggiunto
	--declare @m				varchar(max)	-- Messaggio di errore

	-- Verifica che non siano presenti transazioni di altre sp: se presenti non apre la transazione
	declare @DoTran bit
	set @DoTran = (select case when @@TRANCOUNT = 0 then 1 else 0 end)

	begin try

		if (@DoTran = 1) Begin tran t;

			Declare @DataMov			SmallDatetime	
			Declare @Cd_MGEsercizio		Char(4)			
			Declare @Id_DesRet 			Tinyint			
			Declare @Ret				Smallint		

			-- Recupera i parametri utili all'invetario
			Select 
				@DataMov			= xMOIN.DataOra,
				@Cd_MGEsercizio		= xMOIN.Cd_MGEsercizio,
				@Id_DesRet			= (Select MG_Id_MGMovDes_RET From BLSSettings),
				@Ret				= 1 -- per ora solo positive! da mettere su impostazioni (Select * From xMOImpostazioni)	--<< Iif(lRetPos, +1, -1)			 >>
			from
				xMOIN
			where
				Id_xMOIN = @Id_xMOIN

			if (@INRig_AllOut = 1) begin
				-- L'operatore ha richiesto di smarcare tutte le righe in lavorazione come validate
				update xMOINRig set
					QtaRilevata = Quantita
				where 
						Id_xMOIN = @Id_xMOIN			-- Le rige della testa IN
					And InLavorazione = 1				-- In lavorazione nel terminale
					And QtaRilevata is null				-- Con quantità rilevata NULLA
					And Id_MGMovInt is null				-- Non evase da movimenti di rettifica
			end

			-- Contine le righe da trasformare in inventario con le quantità contabili e le quantità rilevate utili al calcolo delle rettifiche
			declare @inrig as table (Id_xMOINRig int, Quantita numeric(18,8), QtaRilevata numeric(18,8))

			-- Prepara i dati da gestire
			insert into @inrig (Id_xMOINRig, QtaRilevata)
			select 
				Id_xMOINRig
				, QtaRilevata
			From 
				xMOINRig
			where 
					Id_xMOIN = @Id_xMOIN			-- Le rige della testa IN
				And InLavorazione = 1				-- In lavorazione nel terminale
				And not QtaRilevata is null			-- Con quantità rilevata
				And Id_MGMovInt is null				-- Non evase da movimenti di rettifica

			-- Verifica che ci siano righe da rettificare
			If (@@ROWCOUNT > 0) begin

				-- Aggiorno la quantità CONTABILE per essere certi della rettifica da effetuare
				-- potrebbe esserci uno sfasamento temporale e la Quantita di xMOINRig potrebbe essere diversa da quella reale
				update @inrig set
				Quantita = isnull((select 
									mgd.Quantita 
								from 
									MGGiacEx(@Cd_MGEsercizio) mgd 
								where
										mgd.Cd_MG				= r.Cd_MG
									And mgd.Cd_AR				= r.Cd_Ar 
									And isnull(mgd.Cd_MGUbicazione, '')		= isnull(r.Cd_MGUbicazione, '')
									And isnull(mgd.Cd_ARLotto, '')			= isnull(r.Cd_ARLotto, '')
									And isnull(Cd_DOSottoCommessa, '')		= isnull(r.Cd_DOSottoCommessa, '')
								), 0)
				from
					xMOINRig r
						inner join @inrig ir on r.Id_xMOINRig = ir.Id_xMOINRig

				-- Crea un movimento di testa solo se ci sono realmente righe da create (ir.QtaRilevata <> ir.Quantita)
				if exists(select * from @inrig where QtaRilevata <> Quantita) begin
	
					Insert Into MgMovInt (DataMov, Descrizione) 
					select 
						xMOIN.DataOra
						, xMOIN.Descrizione
					from
						xMOIN
					where
						Id_xMOIN = @Id_xMOIN
	
					-- Recupere l'Id di testa generato
					Select  @Id_MgMovInt = Scope_Identity()

					if (isnull(@Id_MgMovInt, 0) = 0) begin
						set @r = -100; set @m = 'Impossibile generare il movimento di testa di MGMovInt!!'; goto exitsp;
					end

					-- ESEGUI L'INSERIMENTO CON UN CURSORE PER AGGIORNARE L'Id SU INRig
					declare @Id_xMOINRig		int

					-- Crea i movimenti
					Insert Into MgMov 
						(Id_MgMovInt, Cd_AR, Cd_MG, Cd_MGUbicazione
						, Cd_ARLotto, Cd_DoSottoCommessa, PadreComponente, Cd_MGEsercizio
						, DataMov, Id_MGMovDes, PartenzaArrivo, Quantita
						, Valore, Ret)
					--, Id_DoDB
					Select				
						@Id_MgMovInt, Cd_AR, Cd_MG, Cd_MGUbicazione
						, Cd_ARLotto, Cd_DoSottoCommessa, 'P', @Cd_MGEsercizio
													-- E' la quantità ricalcolata nella transazione
						, @DataMov, @Id_DesRet, 'A', ir.QtaRilevata - ir.Quantita, 0, @Ret
					From 
						xMOINRig 
							inner join @inrig ir on xMOINRig.Id_xMOINRig = ir.Id_xMOINRig
					where
						-- la quamtità da rettificare deve essere diversa da zero
						ir.QtaRilevata <> ir.Quantita

					--, Id_DoDB

					-- Aggiorna il movimento creato in xMOINRig e laquantità ricalcolata
					update xMOINRig set
						Id_MGMovInt = @Id_MgMovInt
						, Quantita	= ir.Quantita
					From 
						xMOINRig 
							inner join @inrig ir on xMOINRig.Id_xMOINRig = ir.Id_xMOINRig
				end 

				-- Aggiorna le righe coinvolte nella creazione
				update xMOINRig set
					InLavorazione = 0 -- Rimuove tutte le righe in lavorazione
				From 
					xMOINRig 
						inner join @inrig ir on xMOINRig.Id_xMOINRig = ir.Id_xMOINRig

			end

			set @r = @@ROWCOUNT

			-- Imposta la testa IN come Da storicizzare se richiesto 
			if (@IN_Chiudi = 1) 
				update xMOIN set Stato = 1 where Id_xMOIN = @Id_xMOIN

		IF (@DoTran = 1) And (@@trancount > 0) Commit Tran t;

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
	-- Se la transazione è ancora presente la annulla
	if (@DoTran = 1) And (@@trancount > 0) Rollback tran
	-- restituisce il risultato dei controlli con una select
	select 
			Result			= @r, 
			Id_MgMovInt		= @Id_MgMovInt, 
			Messaggio		= isnull(@m, 'Generazione movimenti di rettifica eseguiti con successo.')

	return @r
end 
go

create procedure xmosp_xMOIN_MakeOne_MGMov (
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)
	, @Descrizione			varchar(30)		
	, @Cd_MGEsercizio		char(4)
	, @DataOra				smalldatetime
	, @Cd_MG				char(5)
	, @Cd_MGUbicazione		varchar(20)
	, @Cd_ARLotto			varchar(20) 
	, @Cd_DOSottoCommessa	varchar(20)
	, @Cd_AR				varchar(20)
	, @QtaRilevata			numeric(18,8)
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore

	-- controllare che l'esericizio non sia vuoto 
	if not exists(select * from MGEsercizio where Cd_MGEsercizio = isnull(@Cd_MGEsercizio, '')) begin
		set @r = -10; set @m = 'Esercizio di Magazzino errato o mancante!!'; goto exitsp;
	end

	-- controllare che il mg non sia vuoto 
	if not exists(select * from MG where Cd_MG = isnull(@Cd_MG, '')) begin
		set @r = -20; set @m = 'Magazzino errato o mancante!!'; goto exitsp;
	end

	-- Verifica che la quantità sia maggiore di zero
	if isnull(@QtaRilevata, 0) < 0 begin
		set @r = -10; set @m = 'La quantità rilevata deve essere maggiore uguale a zero!!'; goto exitsp;
	end
	
	begin try

		-- Normalizzazione
		if ISNULL(@Cd_ARLotto, '') = ''						set @Cd_ARLotto = null;
		if ISNULL(@Cd_MGUbicazione, '') = ''				set @Cd_MGUbicazione = null;
		if ISNULL(@Cd_DOSottoCommessa, '') = ''				set @Cd_DOSottoCommessa = null;

		declare @xMOIN		as table (Result int, Id_xMOIN int, Messaggio varchar(max))
		declare @xMOIN_Make as table (Result int, Id_xMOIN int, Messaggio varchar(max))

		declare @Id_xMOIN			int				-- Id testa IN da salvare
		declare @Id_xMOINRig		int				-- Id riga IN da salvare

		begin transaction t1
		
			-- Aggiunge la testa
			insert into @xMOIN (Result, Id_xMOIN, Messaggio)
			exec xmosp_xMOIN_Save @Terminale			
								, @Cd_Operatore			
								, @Descrizione			
								, @Cd_MGEsercizio
								, @DataOra			
								, @Cd_MG				
								, @Cd_MGUbicazione	
								, 1
								, @Id_xMOIN

			select @r = Result, @Id_xMOIN = Id_xMOIN, @m = Messaggio from @xMOIN
			if (@r <= 0) begin 
				goto exitsp;	
			end

			-- Aggiunge la riga
			insert into xMOINRig (Id_xMOIN, Terminale, Cd_Operatore, Cd_AR, Quantita, QtaRilevata, Cd_ARMisura, FattoreToUM1, Cd_DOSottoCommessa, Cd_ARLotto, Cd_MG, Cd_MGUbicazione, InLavorazione, Id_MGMovInt)
			select 
				@Id_xMOIN
				, Terminale				= @Terminale
				, Cd_Operatore			= @Cd_Operatore
				, Cd_AR					= Ar.Cd_AR
				, Quantita				= 0	-- Viene ricalcolata da xmosp_xMOIN_Make_MGMov
				, QtaRilevata			= @QtaRilevata
				, Cd_ARMisura			= upper(um.Cd_ARMisura)
				, FattoreToUM1			= um.UMFatt
				, Cd_DOSottoCommessa 	= @Cd_DOSottoCommessa
				, Cd_ARLotto			= @Cd_ARLotto
				, Cd_MG					= @Cd_MG
				, Cd_MGUbicazione		= @Cd_MGUbicazione
				, InLavorazione			= 1							-- Vero perchè righe che saranno gestite dal client. Attenzione mettere a 0 al momento del salvataggio
				, Id_MGMovInv			= null
			From
				AR 
					inner join ARARMisura um on AR.Cd_AR = um.Cd_AR And um.DefaultMisura = 1
			Where 
				Ar.Cd_AR = @Cd_AR

			-- Recupera l'id di riga salvato
			set @Id_xMOINRig = @@IDENTITY

			-- Genera il  movimento
			--insert into @xMOIN_Make (Result, Id_xMOIN, Messaggio)
			exec @r = xmosp_xMOIN_Make_MGMov @Terminale			
										, @Cd_Operatore		
										, @Id_xMOIN			
										, 0	-- @INRig_AllOut		
										, 1	-- @IN_Chiudi		
										, @m output 
			--select @r = Result, @Id_xMOIN = Id_xMOIN, @m = Messaggio from @xMOIN_Make
			if (@r <= 0) begin 
				goto exitsp;	
			end

		commit transaction t1

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		if @@TRANCOUNT > 0 rollback transaction;
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOINRig		= @Id_xMOIN, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
		return @r
end 
go

-- Salvataggio dati di testa dell'inventario
create procedure xmosp_xMOIN_Save(
	@Terminale				varchar(39)
	, @Cd_Operatore			varchar(20)
	, @Descrizione			varchar(30)		
	, @Cd_MGEsercizio		char(4)
	, @DataOra				smalldatetime
	, @Cd_MG				char(5)
	, @Cd_MGUbicazione		varchar(20)
	, @Top					int 
	-- , @Cd_DOSottoCommessa	varchar(20) -- ### Da sviluppare
	, @Id_xMOIN				int 
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	Begin try

		-- controllare che l'esericizio non sia vuoto 
		if not exists(select * from MGEsercizio where Cd_MGEsercizio = isnull(@Cd_MGEsercizio, '')) begin
			set @r = -10; set @m = 'Esercizio di Magazzino errato o mancante!!'; goto exitsp;
		end

		-- controllare che l'esericizio non sia vuoto 
		if ISNULL(@DataOra, '') = ''  begin
			set @r = -15; set @m = 'Inserire la data del movimento!!'; goto exitsp;
		end

		-- controllare che il mg non sia vuoto 
		if not exists(select * from MG where Cd_MG = isnull(@Cd_MG, '')) begin
			set @r = -20; set @m = 'Magazzino errato o mancante!!'; goto exitsp;
		end
		-- Codice magazzino non trovato
		if not exists(select * from MG where Cd_MG = @Cd_MG) begin
			set @r = -30; set @m = 'Magazzino non trovato!!'; goto exitsp;
		end
		-- Descrizione non trovata
		if (isnull(@Descrizione, '') = '') begin
			set @r = -40; set @m = 'Inserire una descrizione!!'; goto exitsp;
		end 


		-- Il controllo è stato eliminato in quanto il salvataggio del movimento interno si preoccupa sempre di corregge la 
		-- giacenza contabile prima del salvataggio in modo da evitare incongrueneze

		-- Controlla la presenza di un inventario ancora aperto per il magazzino e/o ubicazione se sono in addnew
		--if (isnull(@Id_xMOIN, 0) = 0) begin
		--	declare @Test_Id_xMOIN		int
		--	declare @Test_Terminale		varchar(39)
		--	declare @Test_Cd_Operatore	varchar(20)

		--	select
		--		@Test_Id_xMOIN			= Id_xMOIN
		--		, @Test_Terminale		= Terminale
		--		, @Test_Cd_Operatore	= Cd_Operatore
		--	from 
		--		xMOIN 
		--	where 
		--			Cd_MGEsercizio				= @Cd_MGEsercizio 
		--		And Cd_MG						= @Cd_MG
		--		And isnull(Cd_MGUbicazione, '')	= isnull(@Cd_MGUbicazione, '')
		--		And xMOIN.Stato					= 0	-- in compilazione

		--	--if (isnull(@Test_Terminale, '') <> '') begin
		--	--	set @r = -50; set @m = 'Esiste un invetario aperto nel terminale ' + @Test_Terminale + ' per l''operatore ' + @Test_Cd_Operatore + ' (id = ' + ltrim(str(@Test_Id_xMOIN)) + ')!!'; goto exitsp;
		--	--end			
		--end

		-- Normalizzazione
		set @Cd_MGUbicazione = case when isnull(@Cd_MGUbicazione, '') <> '' then @Cd_MGUbicazione else null end 
					
		if (isnull(@Id_xMOIN, 0) = 0) begin

			Insert Into	xMOIN	(Terminale	, Cd_Operatore	, Descrizione	, Stato	, DataOra	, Cd_MGEsercizio, Cd_MG	, Cd_MGUbicazione, [Top])
			Values				(@Terminale	, @Cd_Operatore	, @Descrizione	,	0	, @DataOra	, @Cd_MGEsercizio, @Cd_MG, @Cd_MGUbicazione, @Top)
			Set @id= @@IDENTITY;

		end else begin

			update xMOIN set
				  Terminale				= @Terminale
				  , Cd_Operatore		= @Cd_Operatore
				  , Descrizione			= @Descrizione
				  , Stato				= 0 -- In compilazione
				  , DataOra				= @DataOra
				  , Cd_MG				= @Cd_MG
				  , Cd_MGUbicazione		= @Cd_MGUbicazione
				  , [Top]				= @Top
			where	
				Id_xMOIN = @Id_xMOIN

			set @id = @Id_xMOIN;
		end

		set @r = (case when @id > 0 then 1 else 0 end);
		
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMOIN		= @id, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
		
		return @r
end 
go

-- Insert in xMOINRig degli articoli da inventariare per il magazzino selezionato
create procedure xmosp_xMOINRig_AR (
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)		
	, @Id_xMOIN			int			
	, @Cd_MGEsercizio	char(4)
	, @Cd_MG			char(5)			
	, @Cd_MGUbicazione	varchar(20)		
) 
/*ENCRYPTED*/
as begin 

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	declare @TopE			int				-- top effettivo dei nuovi record da inserire in xMOINRig = @Top - record in xMOINRig con Id_MGMovInt == null

	begin try

		-- controllare che l'esericizio non sia vuoto 
		if not exists(select * from MGEsercizio where Cd_MGEsercizio = isnull(@Cd_MGEsercizio, '')) begin
			set @r = -10; set @m = 'Esercizio di Magazzino errato o mancante!!'; goto exitsp;
		end

		-- controllare che il mg non sia vuoto 
		if not exists(select * from MG where Cd_MG = isnull(@Cd_MG, '')) begin
			set @r = -20; set @m = 'Magazzino errato o mancante!!'; goto exitsp;
		end

		-- Imposta il @Top a 100 se 0 
		declare @Top int
		set @Top = isnull((select [Top] from xMOIN where Id_xMOIN = @Id_xMOIN), 0); 
		set @Top = case when @Top = 0 then 20 else @Top end

		-- Righe in lavorazione sul terminale
		declare @TopL int
		-- Calcola il top effettivo di record da inserire in xMOINRig (esclude dal top tutti i record che andranno nuovamente gestiti)
		set @TopL = cast((
							Select COUNT(*) 
							From xMOINRig 
							Where 
								-- Esclude le righe incluse
									Id_xMOIN = @Id_xMOIN 		-- Stessa testa
								And InLavorazione = 1			-- Gestite dal terminale
								--Bug: Tutte le righe concorrono al conteggio di quelle in lavorazione dal terminale!
								--And QtaRilevata is null			-- Con quantità non rilevata
								And Id_MGMovInt is null			-- Non storicizzate nei movimenti
								And Terminale = @Terminale		-- Di questo terminale
							) as int);
		
		-- Se il top effettivo minore delle righe in lavorazione non seleziona nessuna riga 
		set @TopE = case when @Top >= @TopL then @Top - @TopL else 0 end

		if (@TopE > 0) begin	
			-- Insert in xMOINRig 
			insert into xMOINRig (Id_xMOIN, Terminale, Cd_Operatore, Cd_AR, Quantita, QtaRilevata, Cd_ARMisura, FattoreToUM1, Cd_DOSottoCommessa, Cd_ARLotto, Cd_MG, Cd_MGUbicazione, InLavorazione, Id_MGMovInt)
			select top (@TopE)
				@Id_xMOIN
				, Terminale				= @Terminale
				, Cd_Operatore			= @Cd_Operatore
				, Cd_AR					= mgd.Cd_AR
				, Quantita				= mgd.Quantita
				, QtaRilevata			= null
				, Cd_ARMisura			= upper(um.Cd_ARMisura)
				, FattoreToUM1			= um.UMFatt
				, Cd_DOSottoCommessa 	= mgd.Cd_DOSottoCommessa
				, Cd_ARLotto			= mgd.Cd_ARLotto
				, Cd_MG					= mgd.Cd_MG
				, Cd_MGUbicazione		= mgd.Cd_MGUbicazione
				, InLavorazione			= 1							-- Vero perchè righe che saranno gestite dal client. Attenzione mettere a 0 al momento del salvataggio
				, Id_MGMovInv			= null
			From
				MGGiacEx(@Cd_MGEsercizio) mgd 
					inner join ARARMisura um on mgd.Cd_AR = um.Cd_AR And um.DefaultMisura = 1
					inner join AR on ar.Cd_AR = mgd.Cd_AR
			Where 
				mgd.Cd_MG = @Cd_MG
				And (isnull(@Cd_MGUbicazione, '') = '' Or mgd.Cd_MGUbicazione = @Cd_MGUbicazione)
				And (isnull(@Id_xMOIN, 0) = 0 
						Or mgd.Cd_AR + mgd.Cd_MG + 'U' + isnull(mgd.Cd_MGUbicazione, '') + 'L' + isnull(mgd.Cd_ARLotto, '') + 'S' + isnull(mgd.Cd_DOSottoCommessa, '') 
						-- Esclude le righe già inventariate
						Not In (
							Select 
								Cd_AR + Cd_MG + 'U' + isnull(Cd_MGUbicazione, '') + 'L' + isnull(Cd_ARLotto, '') + 'S' + isnull(Cd_DOSottoCommessa, '')
							from
								xMOINRig
							where
								-- Stessa testa IN
								Id_xMOIN = @Id_xMOIN
							)
					)
		end
		---- Verifica il numero di record inseriti 
		--if (@@ROWCOUNT = 0) begin
		--	-- Nessun record inserito nel magazzino e per i filtri impostati
		--	set @r = 0; set @m = 'Nessun articolo da inventariare.'; goto exitsp;
		--end

		set @r = 1;
		
	end try 
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dell'insert dei record 
		select 
			Result			= @r, 
			Messaggio		= isnull(@m, 'Insert effettuato con successo.')

		return @r
end 
go

-- Update della quantità rilevata di un articolo
create procedure xmosp_xMOINRig_AR_Save (
	@Terminale			varchar(39),
	@Cd_Operatore		varchar(20),
	@Id_xMOINRig		int,
	@QtaRilevata		numeric(18,8)
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	-- controllo se ho l'id di testa 
	if(isnull(@Id_xMOINRig, 0) = 0) begin
		set @r = -10; set @m = 'ATTENZIONE: Nessuna appartenenza ad un inventario per la riga!!'; goto exitsp;
	end

	-- Verifica che la quantità sia maggiore di zero 
	if isnull(@QtaRilevata, 0) < 0 begin
		set @r = -10; set @m = 'La quantità rilevata deve essere maggiore uguale a zero!!'; goto exitsp;
	end
	
	begin try
		
		update xMOINRig set 
			QtaRilevata = @QtaRilevata
		where
			Id_xMOINRig = @Id_xMOINRig

		set @r = @@ROWCOUNT;
		-- recupera l'id salvato
		set @id = @Id_xMOINRig;

		if(isnull(@id, 0) = 0) begin
			set @r = -9999; set @m = 'Impossibile aggiornare la riga di inventario!!'; goto exitsp;
		end

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOINRig		= @id, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
GO

-- Aggiunge un articolo da inventariare in xMOINRig 
create procedure xmosp_xMOINRig_AR_Add (
	@Terminale			varchar(39),
	@Cd_Operatore		varchar(20),
	@Id_xMOIN			int,
	@Cd_AR				varchar(20), 
	@Cd_MGEsercizio		char(4),
	@Cd_MG				char(5),
	@Cd_MGUbicazione	varchar(20),	
	@Cd_ARLotto			varchar(20), 
	@Cd_DOSottoCommessa	varchar(20)
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore
	declare @id				int				-- identificativo del record aggiunto

	-- controllo se ho l'id di testa 
	if(isnull(@Id_xMOIN, 0) = 0) begin
		set @r = -10; set @m = 'ATTENZIONE: Nessuna appartenenza ad un inventario per la riga (Id_xMOIN)!!'; goto exitsp;
	end
	
	-- controllare che l'esericizio non sia vuoto 
	if not exists(select * from MGEsercizio where Cd_MGEsercizio = isnull(@Cd_MGEsercizio, '')) begin
		set @r = -20; set @m = 'Esercizio di Magazzino errato o mancante!!'; goto exitsp;
	end

	-- controllare che il mg non sia vuoto 
	if not exists(select * from MG where Cd_MG = isnull(@Cd_MG, '')) begin
		set @r = -30; set @m = 'Magazzino errato o mancante!!'; goto exitsp;
	end

	-- controllare che l'articolo non sia vuoto 
	if not exists(select * from AR where Cd_AR = isnull(@Cd_AR, '')) begin
		set @r = -40; set @m = 'Articolo errato o mancante!!'; goto exitsp;
	end

	-- controlla se la commessa nel caso in cui viene passata alla funzione sia una commessa valida
	if isnull(@Cd_DOSottoCommessa, '') != '' AND @Cd_DOSottoCommessa not in (select Cd_DOSottoCommessa from DOSottoCommessa) begin
		set @r = -50; set @m = 'Commessa errata!!' goto exitsp;
	end

	-- controlla se il lotto nel caso in cui viene passato alla funzione sia un lotto valido
	if not @Cd_ARLotto is null AND @Cd_ARLotto not in (select @Cd_ARLotto from ARLotto) begin
		set @r = -60; set @m = 'Lotto errato!!' goto exitsp;
	end

	-- controllo che la riga non sia attualmente gestita da un altro terminale
	declare @Test_Terminale		varchar(39)
	declare @Test_Cd_Operatore	varchar(20)

	select 
		@Test_Terminale			= xMOINRig.Terminale
		, @Test_Cd_Operatore	= xMOINRig.Cd_Operatore
	from 
		xMOIN 
			inner join xMOINRig on xMOIN.Id_xMOIN = xMOINRig.Id_xMOIN 
	where 
			xMOINRig.Id_xMOIN							= @Id_xMOIN		
		And xMOINRig.Cd_AR								= @Cd_AR
		And isnull(xMOINRig.Cd_DOSottoCommessa, '')		= isnull(@Cd_DOSottoCommessa, '')
		And isnull(xMOINRig.Cd_ARLotto, '')				= isnull(@Cd_ARLotto, '')
		And xMOINRig.Cd_MG								= @Cd_MG
		And isnull(xMOINRig.Cd_MGUbicazione, '')		= isnull(@Cd_MGUbicazione, '')
		And xMOINRig.InLavorazione						= 1							

	if (isnull(@Test_Terminale, '') <> '') begin
		set @r = -70; set @m = 'L''articolo è correntemente in gestione del terminale ' + @Test_Terminale + ' per l''operatore ' + @Test_Cd_Operatore + '!!'; goto exitsp;
	end

	-- Normalizza i dati
	set @Cd_MGUbicazione	= case when ISNULL(@Cd_MGUbicazione, '') <> '' then @Cd_MGUbicazione else null end
	set @Cd_ARLotto			= case when ISNULL(@Cd_ARLotto, '') <> '' then @Cd_ARLotto else null end
	set @Cd_DOSottoCommessa	= case when ISNULL(@Cd_DOSottoCommessa, '') <> '' then @Cd_DOSottoCommessa else null end
	
	-- declare @row table (Id_xMOINRig, Id_xMOIN, Cd_AR, DataOra, Quantita, QtaRilevata, Cd_ARMisura, UMFatt, Cd_DOSottoCommessa, Cd_ARLotto, Cd_MG, Cd_MGUbicazione, FattoreToUM1, Id_MGMovInt)

	begin try

		--insert into @row		
		--select top 1
		--	*
		--from 
		--	xMOINRig 
		--where
		--	Cd_MG = @Cd_MG 
		--	and Cd_AR = @Cd_AR 
		--	and (isnull(@Cd_ARLotto, '') = '' Or Cd_ARLotto = @Cd_ARLotto)
		--	and (isnull(@Cd_MGUbicazione, '') = '' Or Cd_MGUbicazione = @Cd_MGUbicazione)
		--	and (isnull(@Cd_DOSottoCommessa, '') = '' Or Cd_DOSottoCommessa= @Cd_DOSottoCommessa)

		--if((select count(*) from @row where Id_MGMovInt is not null) > 0 Or (select count(*) from @row) = 0) begin
			
		-- insert della riga in INRig 	
		insert into xMOINRig (
			Id_xMOIN, Terminale, Cd_Operatore, Cd_AR, Quantita, Cd_ARMisura
			, FattoreToUM1, Cd_DOSottoCommessa, Cd_ARLotto, Cd_MG
			, Cd_MGUbicazione, InLavorazione 
			)
		select 
			Id_xMOIN				= @Id_xMOIN
			, Terminale				= @Terminale
			, Cd_Operatore			= @Cd_Operatore
			, Cd_AR					= ar.Cd_AR
			, Quantita				= isnull(mgd.Quantita, 0)
			, Cd_ARMisura			= upper(um.Cd_ARMisura)
			, FattoreToUM1			= um.UMFatt
			, Cd_DOSottoCommessa 	= @Cd_DOSottoCommessa
			, Cd_ARLotto			= @Cd_ARLotto
			, Cd_MG					= @Cd_MG
			, Cd_MGUbicazione		= @Cd_MGUbicazione
			, InLavorazione			= 1							-- Vero perchè righe che saranno gestite dal client. Attenzione mettere a 0 al momento del salvataggio
		from
			AR 
				inner join ARARMisura um on ar.Cd_AR = um.Cd_AR And um.DefaultMisura = 1
				left join (
					select Cd_AR, Quantita 
					from dbo.MGGiacEx(@Cd_MGEsercizio)
					where
						Cd_AR = @Cd_AR 
						And Cd_MG = @Cd_MG
						And isnull(Cd_MGUbicazione, '') = isnull(@Cd_MGUbicazione, '')
						And isnull(Cd_ARLotto, '') = isnull(@Cd_ARLotto, '')
						And isnull(Cd_DOSottoCommessa, '') = isnull(@Cd_DOSottoCommessa, '')
						/*  Vecchia gestione errata in quanto se ad esempio l'ubicazione arriva vuota devono essere escluse tutte le righe con ubi <> da vuoto*/
						--And (isnull(@Cd_MGUbicazione, '')		= '' Or Cd_MGUbicazione = @Cd_MGUbicazione)
						--And (isnull(@Cd_ARLotto, '')			= '' Or Cd_ARLotto = @Cd_ARLotto)
						--And (isnull(@Cd_DOSottoCommessa, '')	= '' Or Cd_DOSottoCommessa = @Cd_DOSottoCommessa)
					) mgd on ar.Cd_AR = mgd.Cd_AR
		where 
			ar.Cd_AR = @Cd_AR 
				
		set @r = @@ROWCOUNT;
		-- recupera l'id salvato
		set @id = @@IDENTITY;

		if(isnull(@id, 0) = 0) begin
			set @r = -9999; set @m = 'Impossibile aggiungere la riga di inventario per ' + @Cd_AR + '!!'; goto exitsp;
		end

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOINRig		= @id, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

create procedure xmosp_xMOSpedizione_Close(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Cd_xMOCodSpe		varchar(20)
	, @msgout			varchar(max)	output	-- Messaggio 
)
/*ENCRYPTED*/
as begin	

	set nocount on
	declare @r				int				-- risultato della sp
	begin try
		update xMOCodSpe set Attiva = 0 where Cd_xMOCodSpe = @Cd_xMOCodSpe
		set @r = 1; -- Tutto ok
	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
		set @msgout = isnull(@msgout, 'Salvataggio effettuato con successo.')
		return @r
end 
go


create procedure xmosp_xMOSpedizione_SaveRL(
	@Terminale			varchar(39)
	, @Cd_Operatore		varchar(20)
	, @Id_DOTess		varchar(max)		-- Identificativi del prelievo
	, @Cd_DO			char(3)				-- Tipo di documento da generare 
)
/*ENCRYPTED*/
as begin	

	set nocount on

	declare @r				int				-- risultato della sp
	declare @Id_xMORL		int				-- identificativo del record aggiunto
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		-- Normalizzazione

		-- La stringa dei prelievi deve iniziare e finire con "," e non deve contenere spazi!
		set @Id_DOTess = 
						case when left(@Id_DOTess, 1) <> ',' then ',' else '' end		-- Virgola iniziale
						+ replace(@Id_DOTess, ' ', '')									-- elimina gli spazi
						+ case when right(@Id_DOTess, 1) <> ',' then ',' else '' end	-- Virgola finale

		-- Verifiche
				
		declare @NRec int
		-- Verifica il cliente e la destinazione dal prelivo se restituisce più di un record i documenti selezionati non sono coerenti
		set @NRec = (
						select 
							count(*) 
						from (
								select
									Cd_CF
									, Cd_CFDest
									, xCd_xMOCodSpe
								from 
									DOTes 
								where 
									DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))
								group by 
									Cd_CF
									, Cd_CFDest
									, xCd_xMOCodSpe
							) as a 
					)

	
		-- Verifica la coerenza dei dati
		if (@NRec > 1) begin
			set @r = -10; set @m = 'Errore! I documenti selezionati devono avere dati coerenti: cliente, destinazione e spedizione!'; goto exitsp;
		end

		-- Recupero dati
		declare @Cd_CF				char(7)
		declare @Cd_CFDest			char(3)	
		declare @Cd_xMOCodSpe		varchar(15)

		select top 1  
			@Cd_CF				= Cd_CF
			, @Cd_CFDest		= Cd_CFDest
			, @Cd_xMOCodSpe		= xCd_xMOCodSpe
		from 
			DOTes
		where
			DOTes.Id_DOTes In (select id from dbo.xmofn_Ids_Split(@Id_DOTess))


		-- recupra i magazzini 
		declare @Cd_MG_P	char(5)
		declare @Cd_MG_A	char(5)

		select 
			@Cd_MG_P	= Cd_MG_P
			, @Cd_MG_A	= Cd_MG_A
		from
			DO
				inner join MGCausale on DO.Cd_MGCausale = MGCausale.Cd_MGCausale
		where 
			DO.Cd_DO = @Cd_DO

		-- Id del prelievo
		--declare @Id_DOTess	varchar(max)
		--set @Id_DOTess = ',' + ltrim(rtrim(cast(@Id_DOTess as varchar(max)))) + ','

		begin transaction 

			-- Creazione della testa
			exec dbo.xmosp_xMORL_Save
				@Terminale	
				, @Cd_Operatore		
				, @Cd_DO	
				, null			-- @DataDoc	### creare interfaccia in moovi per permettere l'inserimento della data all'operatore
				, @Cd_CF		
				, @Cd_CFDest	
				, null			-- @Cd_xMOLinea
				, ''			-- @NumeroDocRif
				, null			-- @DataDocRif
				, @Cd_MG_P		
				, @Cd_MG_A		
				, null			-- @Cd_DOSottoCommessa
				, null			-- @Id_xMORL

			set @Id_xMORL	= @@IDENTITY

			-- Aggiorna i dati della lista di carico 
			update xMORL set 
				Cd_xMOCodSpe = @Cd_xMOCodSpe
			where 
				Id_xMORL = @Id_xMORL

			-- Creazione dei prelievi associati alla nuova testa di RL (se @r < 0 esce con errore)
			exec @r = xmosp_xMORLPrelievo_Save @Terminale, @Cd_Operatore, @Id_xMORL, @Id_DOTess, @m output
			if (@r < 0) goto exitsp;

		commit transaction

		set @r = 1; -- Tutto ok

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMORL		= @Id_xMORL,
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

-- Eliminazione di un inventario
create procedure xmosp_xMOIN_Delete (
	@Terminale			varchar(39)		
	, @Cd_Operatore		varchar(20)
	, @Id_xMOIN_Del		int		
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @Id_xMOIN		int				-- identificativo del record da eliminare
	declare @m				varchar(max)	-- Messaggio di errore

	begin try

		Update xMOIN set
			Stato = 3 -- Annullato
		where 
			Id_xMOIN = @Id_xMOIN_Del

		set @Id_xMOIN	= @Id_xMOIN_Del
		set @r			= @@ROWCOUNT

	end try
	begin catch
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch

exitsp:
		-- restituisce il risultato dei controlli con una select
		select 
				Result			= @r, 
				Id_xMOIN		= @Id_xMOIN,
				Messaggio		= isnull(@m, 'Eliminazione effettuata con successo.')
		return @r
end 
go

-- Crea una rilevazione in moovi se non esistente del documento di Arca passato alla sp
-- Creare stored procedure a cui passo l'id di testa di un documento di arca controllare:
create procedure xmosp_DOTes_To_xMORL(
	 @Terminale		varchar(39) 
	, @Cd_Operatore	varchar(20)  
	, @Id_DOTes		int
)
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore

	-- Nuovo Identificativo di MOOVI creato
	declare @Id_xMORL		int
	
	Begin try

		declare @Cd_DO 		char(3)			 
		set @Cd_DO = (select Cd_DO from DOTes where Id_DOTes = @Id_DOTes)	
		
		-- controllo che l'id del documento non sia vuoto e che esista nella relativa tabella
		if (ISNULL(@Id_DOTes, '') = '' OR not exists (select Id_DOTes from DOTes where Id_DOTes = @Id_DOTes)) begin
			set @r = -10; set @m = 'ID: ' +  @Id_DOTes + ' del documento errato o mancante!!'; goto exitsp;
		end
		--	controllo che il tipo di documento sia attivo per moovi 
		if 	((select xMOAttivo from DO where Cd_DO = @Cd_DO) = 0) begin
			set @r = -20; set @m = 'Documento non attivo per moovi!!'; goto exitsp;
		end
		--	controllo che non sia stato creato da moovi e quindi che non esistono rilevazioni collegate al documento
		if exists (select Id_xMORL from xMORL where Id_DOTes = @Id_DOTes) begin
			set @r = -30; set @m = 'Documento già eistente nelle tabelle di moovi!!'; goto exitsp;
		end

		-- insert dei dati di testa del documento in xmorl
		insert into xMORL (Cd_DO, Terminale, Cd_Operatore, Stato, Id_DOTes, Cd_CF, Cd_CFDest, DataDoc, Cd_xMOLinea, NumeroDocRif, DataDocRif, NotePiede, Targa, Cd_DOSottoCommessa, Cd_DOCaricatore, Cd_xMOCodSpe)
		select 
			Cd_DO
			, Terminale		= @Terminale
			, Cd_Operatore	= @Cd_Operatore
			, Stato			= 4					-- = DaArca --> documento creato in moovi da Arca  
			, Id_DOTes
			, Cd_CF
			, Cd_CFDest
			, DataDoc		
			, xCd_xMOLinea
			, NumeroDocRif
			, DataDocRif
			, NotePiede
			, xTarga
			, Cd_DOSottoCommessa
			, Cd_DOCaricatore
			, xCd_xMOCodSpe
		from
			DOTes
		Where 
			Id_DOTes = @Id_DOTes

		set @Id_xMORL = @@identity;

		--	controllo che abbia pklist attiva 
		if ((select PkLstEnabled from DO where Cd_DO = @Cd_DO) = 1) begin

			-- insert delle righe di packing presenti in arca into xMORLPackListRef
			insert into xMORLPackListRef (Id_xMORL, PackListRef)
			select 
				@Id_xMORL, PackListRef
			from 
				DORigPackList
			where
				Id_DoRig IN (select Id_DoRig from DoRig where Id_DoTes = @Id_DOTes)
			group by 
				PackListRef	

		end
			
		set @r = 1;

	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch
	
	exitsp:
		-- restituisce il risultato dei controlli 
		select 
			Result			= @r, 
			Id_xMORL		= @Id_xMORL, 
			Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')

		return @r
end 
go

create procedure xmosp_ARAlias_Save(
	@Terminale		varchar(39),
	@Cd_Operatore	varchar(20),
	@Cd_AR			varchar(20),
	@Cd_ARMisura	char(2),
	@Alias			varchar(20)
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore

	Begin try

		-- verifico che cd_ar non è vuoto
		if (ISNULL(@Cd_AR, '') = '')begin
			set @r = -10; set @m = 'Specificare un articolo'; goto exitsp;			
		end

		-- verifico che l'alias non è vuoto
		if (ISNULL(@Alias, '') = '')begin
			set @r = -30; set @m = 'Specificare l''alias da inserire'; goto exitsp;			
		end

		-- verifico se l'alias già esiste
		if exists(select Alias from ARAlias where Alias = @Alias and Cd_AR = @Cd_AR) begin
			set @r = -40; set @m = 'Alias già esistente per l''articolo ' + @Cd_AR; goto exitsp;			
		end

		Insert into ARAlias (Cd_AR, Alias, TipoAlias, Cd_ARMisura, Riga)
		values ( 
					@Cd_AR
					, @Alias
					, ''
					, case when ISNULL(@Cd_ARMisura, '') = '' then null else @Cd_ARMisura end
					, ISNULL((select MAX(Riga) from ARAlias where Cd_AR = @Cd_AR group by Cd_AR), 0) + 1
				)
		set @r = 1;
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

		exitsp:
			-- restituisce il risultato dei controlli 
			select 
				Result			= @r, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
	return @r
end
go


create procedure xmosp_xMOMatGiac_Insert_Update (
	@Matricola			varchar(80)		
	, @Cd_AR			varchar(20)		
	, @Cd_ARLotto		varchar(20)		
	, @Quantita			numeric(18,8)	
)
/*ENCRYPTED*/
as begin

	declare @r int = -999999
	declare @m varchar(max) = '' 
	declare @Id_xMOMatGiac		int

	Begin try
		
		set @Id_xMOMatGiac = (select isnull(Id_xMOMatGiac, 0) from xMOMatGiac where Matricola = @Matricola And Cd_AR = @Cd_AR And isnull(Cd_ARLotto, '') = isnull(@Cd_ARLotto, ''))
		
		if @Id_xMOMatGiac > 0
			update xMOMatGiac set Quantita = Quantita + @Quantita where Id_xMOMatGiac = @Id_xMOMatGiac
		else 
			insert into xMOMatGiac (Matricola, Cd_Ar, Cd_ArLotto, Quantita)
			values (@Matricola, @Cd_Ar, @Cd_ArLotto, @Quantita)

		set @r = @@ROWCOUNT

	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:

		select 
			Result			= @r, 
			Messaggio		= @m

	return @r
end
go

-- Inserisce un nuovo codice alternativo
create procedure xmosp_ARCodCF_Save(
	@Terminale		varchar(39),
	@Cd_Operatore	varchar(20),
	@Cd_AR			varchar(20),
	@Cd_CF			char(7),
	@CodAlt			varchar(20),
	@Descrizione	varchar(80)
) 
/*ENCRYPTED*/
as begin

	declare @r				int				-- risultato della sp
	declare @m				varchar(max)	-- Messaggio di errore

	Begin try

		-- verifico che cd_ar non è vuoto
		if (ISNULL(@Cd_AR, '') = '')begin
			set @r = -10; set @m = 'Specificare un articolo'; goto exitsp;			
		end

		-- verifico che il codalt non è vuoto
		if (ISNULL(@CodAlt, '') = '')begin
			set @r = -30; set @m = 'Specificare il codice alternativo da inserire'; goto exitsp;			
		end

		-- verifico che il CF non è vuoto
		if (ISNULL(@Cd_CF, '') = '')begin
			set @r = -40; set @m = 'Specificare cliente o fornitore'; goto exitsp;			
		end

		-- verifico se il codalt già esiste
		if exists(select CodiceAlternativo from ARCodCF where CodiceAlternativo = @CodAlt and Cd_AR = @Cd_AR and Cd_CF = @Cd_CF) begin
			set @r = -60; set @m = 'Codice alternativo per ' + @Cd_CF + ' già esistente per l''articolo ' + @Cd_AR ; goto exitsp;			
		end

		-- se la descrizione è nulla viene inserita quella dell'articolo
		if (ISNULL(@Descrizione, '') = '')begin
			set @Descrizione = (select Descrizione from AR where Cd_AR = @Cd_AR)
		end

		Insert into ARCodCF (Cd_AR, Cd_CF, FornitorePreferenziale, CodiceAlternativo, Descrizione, Ricarica)
		values ( 
					@Cd_AR
					, @Cd_CF
					, 0			-- Di default non sappiamo se è il preferenziale
					, @CodAlt
					, @Descrizione 
					, ''		-- Di default Logistica non gestisce la ricarica
				)
		set @r = 1;
	End try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

		exitsp:
			-- restituisce il risultato dei controlli 
			select 
				Result			= @r, 
				Messaggio		= isnull(@m, 'Salvataggio effettuato con successo.')
	return @r
end
go

create procedure xmosp_MGUbicazione_Assegnazione (
	@Cd_MG					char(5)
	, @Cd_xMOMGCorsia		char(5)
	, @Cd_MGUbicazione		varchar(20)
	, @Descrizione			varchar(80)
	, @xMOColonna			int
	, @xMORiga				int
	, @xMOLarghezzaMks		numeric(18,8)
	, @xMOAltezzaMks		numeric(18,8)
	, @xMOProfonditaMks		numeric(18,8)
	, @xMOVolumeMaxMks		numeric(18,8)
	, @xMOPesoMaxMks		numeric(18,8)
	, @xMOStato				char(1)
)
/*ENCRYPTED*/
as begin
	declare @Result int = 0
	declare @Msg varchar(max) = ''

	begin tran

	begin try
		if exists (select Cd_MGUbicazione from MGUbicazione where Cd_MG = @Cd_MG And Cd_MGUbicazione = @Cd_MGUbicazione) begin
			update MGUbicazione set
				Descrizione			= @Descrizione
				, xCd_xMOMGCorsia	= @Cd_xMOMGCorsia
				, xMOColonna		= @xMOColonna
				, xMORiga			= @xMORiga
				, xMOLarghezzaMks	= @xMOLarghezzaMks
				, xMOAltezzaMks		= @xMOAltezzaMks
				, xMOProfonditaMks	= @xMOProfonditaMks
				, xMOPesoMaxMks		= @xMOPesoMaxMks
				, xMOVolumeMaxMks	= @xMOVolumeMaxMks
				, xMOStato			= @xMOStato
			where
					Cd_MG = @Cd_MG
				And Cd_MGUbicazione = @Cd_MGUbicazione
		end else begin
			insert into MGUbicazione(Cd_MG, xCd_xMOMGCorsia, Cd_MGUbicazione, Descrizione, xMOColonna, xMORiga, xMOStato, xMOLarghezzaMks, xMOAltezzaMks, xMOProfonditaMks, xMOVolumeMaxMks, xMOPesoMaxMks)
			values(@Cd_MG, @Cd_xMOMGCorsia, @Cd_MGUbicazione, @Descrizione, @xMOColonna, @xMORiga, @xMOStato, @xMOLarghezzaMks, @xMOAltezzaMks, @xMOProfonditaMks, @xMOVolumeMaxMks, @xMOPesoMaxMks)
		end

		commit
	end try
	begin catch
		set @Result = abs(error_number()) * -1
		set @Msg = error_message()
		rollback
	end catch

	select @Result as Result, @Msg as Msg
end
go

-- Salva le righe in P prendento tutti gli articoli presenti nel MG partenza e/o nell'ubicazione P indicati nella testa del TR
create procedure xmosp_xMOTRRig_P_FromMGUBI(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Cd_MG_P char(5)
	, @Cd_MGUbicazione_P varchar(20)
	, @Id_xMOTR int
)
/*ENCRYPTED*/
as begin
	
	declare @r int
	declare @m varchar(max)
	
	
	Begin try 

		if(ISNULL(@Id_xMOTR, 0) = 0) begin
			set @r = -10; set @m = 'Errore: valore mancante per il parametro xMOTR!'; goto exitsp;
		end

		if(ISNULL(@Cd_MG_P, '') = '') begin
			set @r = -20; set @m = 'Errore: nessun magazzino di partenza selezionato.'; goto exitsp;
		end

		set @Cd_MGUbicazione_P = case when isnull(@Cd_MGUbicazione_P, '') = '' then null else @Cd_MGUbicazione_P end
	
		declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

		insert into xMOTRRig_P (Id_xMOTR, Terminale, Cd_Operatore, Cd_AR, Cd_ARMisura, FattoreToUM1, Quantita, DataOra, Cd_MG_P, Cd_MGUbicazione_P)
		Select
			@Id_xMOTR
			, @Terminale
			, @Cd_Operatore
			, mg.Cd_AR
			, ARARMisura.Cd_ARMisura
			, ARARMisura.UMFatt
			, Quantita		= Sum(Quantita)		
			, GETDATE()
			, Cd_MG
			, Cd_MGUbicazione
		From
			MGDispEx(@Cd_MGEsercizio) mg
				Inner Join AR         On mg.Cd_AR	= AR.Cd_AR
				Inner Join ARARMisura On AR.Cd_AR   = ARARMisura.Cd_AR And ARARMisura.DefaultMisura = 1
		Where
				Cd_MG						= @Cd_MG_P
			And	isnull(Cd_MGUbicazione, '') = isnull(@Cd_MGUbicazione_P, '')
			And Quantita					> 0
		Group By
			mg.Cd_MG
			, mg.Cd_MGUbicazione
			, mg.Cd_AR
			, ARARMisura.Cd_ARMisura
			, ARARMisura.UMFatt
		
		set @r = 1; set @m = 'Inserimento righe di partenza effettuato'

	End Try

	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		select 
			Result = @r
			, Messaggio = @m	
	return @r

end
go

-- Salva le righe in P prendendole dai documenti selezionati 
create procedure xmosp_xMOTRRig_P_FromDocs (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Cd_MG_P char(5)
	, @Cd_MGUbicazione_P varchar(20)
	, @Id_xMOTR int
	, @Id_DoTess varchar(max)
)
/*ENCRYPTED*/
as begin
	
	declare @r int
	declare @m varchar(max)
	
	
	Begin try 

		if(ISNULL(@Id_xMOTR, 0) = 0) begin
			set @r = -10; set @m = 'Errore: valore mancante per il parametro xMOTR. Selezione fallita!'; goto exitsp;
		end

		if(ISNULL(@Id_DoTess, '') = '') begin
			set @r = -20; set @m = 'Errore: nessun documento selezionato'; goto exitsp;
		end
		
		set @Cd_MGUbicazione_P = case when isnull(@Cd_MGUbicazione_P, '') = '' then null else @Cd_MGUbicazione_P end

		insert into xMOTRRig_P ([Id_xMOTR], [Terminale], [Cd_Operatore], [Cd_AR], [Cd_ARLotto], [Cd_ARMisura], [FattoreToUM1], [Quantita], [DataOra], [Cd_MG_P], [Cd_MGUbicazione_P])
		select 
			@Id_xMOTR
			, @Terminale
			, @Cd_Operatore 
			, DORig.Cd_AR
			, DORig.Cd_ARLotto
			, DORig.Cd_ARMisura
			, DORig.FattoreToUM1
			, DORig.Qta
			, GETDATE()
			, @Cd_MG_P
			, @Cd_MGUbicazione_P
		from 
			DORig 
		where 
				-- Tutti i documenti selezionati dal cliente
				Id_DoTes in (select id from dbo.xmofn_Ids_Split(@Id_DOTess))
			And Cd_AR is not null

		set @r = 1; set @m = 'Righe di partenza inserite con successo';

	End Try

	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		select 
			Result = @r
			, Messaggio = @m	
	return @r
end
go

-- Elimina l'articolo stoccato dalla tabella A e la rimette in T come non stoccata
create procedure xmosp_SMRig_A_Del (
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTRRig_A int
)
/*ENCRYPTED*/
as begin
	
	declare @r int
	declare @m varchar(max)

	begin try
		-- Controllo che l'id non sia vuoto
		if(ISNULL(@Id_xMOTRRig_A, 0) = 0)begin
			set @r = -10; set @m = 'Errore durante l''eliminazione: la riga da eliminare non è stata trovata!'; goto exitsp;
		end 

		exec xmosp_xMOTRRig_A_Del @Terminale, @Cd_Operatore, @Id_xMOTRRig_A

		-- Elimina l'id A dalla tabella xMOTRRig_T
		update xMOTRRig_T set Id_xMOTRRig_A = null where Id_xMOTRRig_A = @Id_xMOTRRig_A

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); 
		goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select
			Result			= @r
			, Messaggio		= isnull(@m, 'Eliminazione effettuato con successo.')

end
go

-- Salva l'articolo nella tabella A come stoccata
create procedure xmosp_xMOTRRig_TA_Save(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTR int							-- id del xMOTR
	, @Quantita numeric(18,8)				-- quantita del articolo
	, @Cd_ARMisura char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @Cd_MG_A char(5)						-- magazzino dove si trova articolo/lotto
	, @Cd_MGUbicazione_A varchar(20)		-- ubicazione magazzino
	, @Id_xMOTRRig_P int					-- id del xMOTRRig_P 
	, @Id_xMOTRRig_T int					-- id della riga temporanea
	--, @Id_xMOTRRig_A int					-- id opzionale per l'update
) 
/*ENCRYPTED*/
as begin
	
	declare @r		int				-- risultato della sp
	declare @id		int				-- identificativo del record aggiunto
	declare @m		varchar(max)	-- Messaggio di errore

	Begin try
	

		declare @r_A_Save as table (Result int, Id_xMOTRRig_A int, Messaggio varchar(max))
		declare @r_T_Save as table (Result int)

		
		
		if(ISNULL(@Quantita, 0) <= 0) begin
			set @r = -10; set @m = 'Quantità indicata minore o uguale a 0. Impossibile stoccare la rilevazione.'; goto exitsp;
		end

		insert into @r_A_Save
		exec xmosp_xMOTRRig_A_Save 
			@Terminale 
			, @Cd_Operatore 
			, @Id_xMOTR 
			, @Id_xMOTRRig_P 
			, @Quantita 
			, @Cd_ARMisura 
			, @Cd_MG_A 
			, @Cd_MGUbicazione_A 
			, null 

		select @r = Result, @id = Id_xMOTRRig_A, @m = Messaggio from @r_A_Save

		if(ISNULL(@id, 0) > 0) begin

			declare @FattoreToUM1_P	numeric(18,8)
			declare @FattoreToUM1_A	numeric(18,8)
			declare @QtaUMP			numeric(18,8)
			-- Recupero FattoreToUM1 di P
			set @FattoreToUM1_P = (Select FattoreToUM1 From xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P) --150
			-- Recupero FattoreToUM1 di A
			set @FattoreToUM1_A = (Select FattoreToUM1 From xMOTRRig_A where Id_xMOTRRig_A = @Id) --150
			-- Recupero la quantità originale di T
			set @QtaUMP = isnull((select QtaUMP from xMOTRRig_T where Id_xMOTRRig_T = @Id_xMOTRRig_T), 0)

			update xMOTRRig_T set 
				Id_xMOTRRig_A = @id
				-- Riconverte la quantità stoccata (A) nella quantità (P) in modo che se l'operatore ha stoccato meno
				-- merce MOOVI!!! è in grado di riproporre ubicazioni
				-- QtaUMP = Qta_A * Fattore_A / Fattore_P
				, QtaUMP = (@Quantita * @FattoreToUM1_A) / @FattoreToUM1_P
				-- Aggiorna anche l'ubicazione perché potrebbe essere stata cambiata dall'operatore
				, Cd_MGUbicazione_A = @Cd_MGUbicazione_A
			where 
				Id_xMOTRRig_T = @Id_xMOTRRig_T

			declare @Exec_T bit = 0 -- TEST A 1

			-- ATTENZIONE!! Tutte le casistiche per cui devo rielaborare T
			-- Se la quantità salvata in A (in UM1) è diversa da quantità T (in UM1)
			if (@Quantita * @FattoreToUM1_A) <> (@QtaUMP * @FattoreToUM1_P) begin
				set @Exec_T = 1
			end
			if (@Exec_T = 1) begin
				insert @r_T_Save				
				exec xmosp_xMOTRRig_T_Save @Terminale, @Cd_Operatore, 0, @Id_xMOTR
			end

			set @r = 1

		end 

	end try
	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); 
		goto exitsp;
	End Catch

	exitsp:
		-- restituisce il risultato dei controlli con una select
		select
			Result			= @r
			, Id_xMOTRRig_A = @id
			, Messaggio		= isnull(@m, 'Inserimento effettuato con successo.')
			--, LoadList		=  

		return @r

end 
go

-- Ricerca dell'ubicazione + adatta assegnabile all'articolo-quantita
create procedure xmosp_xMOTRRig_T_RicercaUbicazione(
	@Terminale			varchar(20)				-- Terminale
	, @Cd_Operatore		varchar(20)				-- Operatore
	, @Id_xMOTRRig_P	int						-- Identificativo P per proporre Ubicazione in T
	, @Quantita			numeric(18,8)			-- Quantità da stoccare
	, @Cd_MG_A			char(5)					-- Magazzino in cui stoccare
	, @Cd_MGUbicazione	varchar(20) output		-- Valore di ritorno: Ubicazione in cui stoccare l'articolo
	, @QtaAssgnabile	numeric(18,8) output	-- Valore di ritorno: quantità assegnabile all'ubicazione trovata
) 
/*ENCRYPTED*/
as begin
	-- Tabella di appoggio per la ricerca delle ubicazioni
	declare @out table (
		Ordinamento				smallint					-- L'ordinamento è impostato per corsia/ubicazione. L'ordinamento per corsia è necessario per proporre in modo ottimizzato il giro che l'operatore deve fare per stoccare la merce
		, Cd_MGUbicazione		varchar(20)					-- Codice ubicazione in cui poter stoccare l'articolo
		, ScortaDisp			numeric(18,8) default 0		-- Quantità di merce accoglibile dall'ubicazione
		, PesoDisp				numeric(18,8) default 0		-- Peso accoglibile dall'ubicazione
		, VolumeDisp			numeric(18,8) default 0		-- Volume accoglibile dall'ubicazione
		, Giacenza				numeric(18,8) default 0		-- Quantità di merce già stoccata nell'ubicazione, utilizzato per proporre un'ubicazione vuota nel caso non si trovasse spazio cercando per peso, volume o scorta
	)

	declare		@Cd_AR			varchar(20)				-- Articolo per cui cercare un'ubicazione
			,	@Esclusioni		xml						-- Ubicazioni escluse dall'operatore. Es.: '<rows><row>00001.A.C01.R02</row><row>00001.A.C01.R03</row></rows>'
	-- Recupera i dati di P
	select 
		@Cd_AR			= Cd_AR
		, @Esclusioni	= Esclusioni
	from
		xMOTRRig_P
	where 
		Id_xMOTRRig_P = @Id_xMOTRRig_P

	-- Se esistono delle ubicazioni specifiche per l'articolo da stoccare cerco una disponibilità solo fra di esse
	if exists(select Cd_MGUbicazione from ARMGUbicazione where Cd_AR = @Cd_AR) begin
		insert into @out(Ordinamento, Cd_MGUbicazione, ScortaDisp, PesoDisp, VolumeDisp)
		select
			Ordinamento			= ROW_NUMBER() over (order by xMOMGCorsia.CPSequenza, ARMGUbicazione.Cd_MGUbicazione)
			, Cd_MGUbicazione	= ARMGUbicazione.Cd_MGUbicazione
			, ScortaDisp		= ARMGUbicazione.xMOScortaMassima
			, PesoDisp			= MGUbicazione.xMOPesoMaxMks
			, VolumeDisp		= MGUbicazione.xMOVolumeMaxMks
		from
			ARMGUbicazione
				inner join MGUbicazione on ARMGUbicazione.Cd_MG = MGUbicazione.Cd_MG And ARMGUbicazione.Cd_MGUbicazione = MGUbicazione.Cd_MGUbicazione
				inner join xMOMGCorsia	on MGUbicazione.xCd_xMOMGCorsia = xMOMGCorsia.Cd_xMOMGCorsia And MGUbicazione.Cd_MG = xMOMGCorsia.Cd_MG
		where
				ARMGUbicazione.Cd_MG = @Cd_MG_A
			And ARMGUbicazione.Cd_AR = @Cd_AR
			And MGUbicazione.xMOTipo = 'S'
	end else begin -- Altrimenti cerco fra tutte le ubicazioni del magazzino specificato
		insert into @out(Ordinamento, Cd_MGUbicazione, ScortaDisp, PesoDisp, VolumeDisp)
		select
			Ordinamento			= ROW_NUMBER() over (order by xMOMGCorsia.CPSequenza, MGUbicazione.Cd_MGUbicazione)
			, Cd_MGUbicazione	= MGUbicazione.Cd_MGUbicazione
			, ScortaDisp		= 0
			, PesoDisp			= MGUbicazione.xMOPesoMaxMks
			, VolumeDisp		= MGUbicazione.xMOVolumeMaxMks
		from
			MGUbicazione
				inner join xMOMGCorsia	on MGUbicazione.xCd_xMOMGCorsia = xMOMGCorsia.Cd_xMOMGCorsia And MGUbicazione.Cd_MG = xMOMGCorsia.Cd_MG
		where
				MGUbicazione.Cd_MG = @Cd_MG_A
			And MGUbicazione.xMOTipo = 'S'
	end

	-- Elimino le ubicazioni escluse dall'operatore
	delete from @out
	where Cd_MGUbicazione in (
		select
			t.x.value('@cd_mgubicazione', 'varchar(20)')
		from @Esclusioni.nodes('/rows/row') t(x)
	)

	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	-- Ricalcolo Quantità, Peso e Volume accoglibile per ogni ubicazione in base a quanto già stoccato in esse
	update @out set
		ScortaDisp		= o.ScortaDisp	- giac.Quantita		-- Sottraggo alla quantità accoglibile quella già presente nell'ubicazione
		, PesoDisp		= o.PesoDisp	- giac.Peso			-- Sottraggo al peso accoglibile quello già presente nell'ubicazione
		, VolumeDisp	= o.VolumeDisp	- giac.Volume		-- Sottraggo al volume accoglibile quello già presente nell'ubicazione
		, Giacenza		= isnull(giac.Quantita, 0)			-- Aumento la giacenza dell'ubicazione così da sapere se già occupata
	from @out o
		inner join (
			-- Sommatoria di Giacenza, Peso e Volume per ogni ubicazione.
			-- Per peso e volume devo moltiplicare la quantità stoccata per il peso/volume unitario di ogni articolo in quanto potrebbero essere differenti
			select
				Cd_MGUbicazione
				, Quantita	= sum(giac.Quantita)
				, Peso		= sum(giac.Quantita * AR.PesoLordoMks)
				, Volume	= sum(giac.Quantita * AR.VolumeMks)
			from
				MGGiacEx(@Cd_MGEsercizio) giac
					inner join AR on giac.Cd_AR	= AR.Cd_AR
			where
				Cd_MG = @Cd_MG_A
			group by
				Cd_MGUbicazione
			) giac on o.Cd_MGUbicazione = giac.Cd_MGUbicazione

	-- Sottraggo la giacenza nelle ubicazioni già assegnata ad altri operatori
	update @out set
		ScortaDisp		= o.ScortaDisp - giac.Quantita		-- Sottraggo alla quantità accoglibile quella già prenotata da altri operatori
		, PesoDisp		= o.PesoDisp - giac.Peso			-- Sottraggo al peso accoglibile quello già prenotata da altri operatori
		, VolumeDisp	= o.VolumeDisp - giac.Volume		-- Sottraggo al volume accoglibile quello già prenotata da altri operatori
		, Giacenza		= o.Giacenza + giac.Quantita		-- Aumento la giacenza dell'ubicazione così da sapere se già occupata
	from @out o
		inner join (
			-- Recupero tutte le righe temporanee di tutti gli utenti e la sommatoria a parità di ubicazione di quantità, peso e volume
			-- Questo mi consente di tenere in considerazione anche le "prenotazioni" degli altri operatori che stanno stoccando merce
			select
				Cd_MGUbicazione		= t.Cd_MGUbicazione_A
				, Quantita			= sum(t.QtaUMP)
				, Peso				= sum(t.QtaUMP * AR.PesoLordoMks)
				, Volume			= sum(t.QtaUMP * AR.VolumeMks)
			from
				xMOTRRig_T t
					inner join xMOTR		on t.Id_xMOTR		= xMOTR.Id_xMOTR
					inner join xMOTRRig_P p	on t.Id_xMOTRRig_P	= p.Id_xMOTRRig_P
					inner join AR			on p.Cd_AR			= AR.Cd_AR
			where
					t.Cd_MGUbicazione_A is not null
				And xMOTR.Stato = 0
				And t.Cd_MG_A = @Cd_MG_A
			group by
				t.Cd_MGUbicazione_A
		) giac	on o.Cd_MGUbicazione = giac.Cd_MGUbicazione
	
	-- SCORTA MASSIMA - Cerco un'ubicazione in cui stoccare l'articolo per scorta massima
	select top 1
		@Cd_MGUbicazione = Cd_MGUbicazione
		-- Calcolo la quantità assegnabile
		, @QtaAssgnabile = case when @Quantita > ScortaDisp then ScortaDisp else @Quantita end
	from @out
	where
		-- tutte le ubicazioni che hanno quantità assegnable
		ScortaDisp > 0
	order by Ordinamento

	-- PESO MASSIMO - Cerco un'ubicazione in cui stoccare l'articolo per scorta massima
	-- Se non ho trovato nessuna ubicazione per scorta
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = Cd_MGUbicazione
			, @QtaAssgnabile = case when (@Quantita * AR.PesoLordoMks) > PesoDisp then cast(PesoDisp / AR.PesoLordoMks as int) else (@Quantita * AR.PesoLordoMks) end
		from @out o, (select PesoLordoMks from AR where Cd_AR = @Cd_AR) AR
		where
			PesoDisp > 0 
		order by Ordinamento
	end

	-- VOLUME MASSIMO - Cerco un'ubicazione in cui stoccare l'articolo per volume massimo
	-- Se non ho trovato nessuna ubicazione per peso
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = Cd_MGUbicazione
			, @QtaAssgnabile = case when (@Quantita * AR.VolumeMks) > VolumeDisp then cast(VolumeDisp / AR.VolumeMks as int) else (@Quantita * AR.VolumeMks) end
		from @out o, (select VolumeMks from AR where Cd_AR = @Cd_AR) AR
		where
			VolumeDisp > 0
		order by Ordinamento
	end

	-- PRIMA LIBERA - Propongo la prima ubicazione vuota
	-- Se non ho trovato nessuna ubicazione per volume
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = o.Cd_MGUbicazione
			, @QtaAssgnabile = @Quantita
		from @out o
		where
			o.Giacenza = 0
		order by o.Ordinamento
	end

	-- Se la quantità assegnabile è nulla la imposta a zero
	set @QtaAssgnabile = ISNULL(@QtaAssgnabile, 0)

	return 1

end
go

-- Prepara l'xml per salvare le ubi escluse in xmotrrig_p
create procedure xmosp_xMOTRRig_T_RicercaUbicazione_Escludi(
	@Terminale					varchar(20)				-- Terminale
	, @Cd_Operatore				varchar(20)				-- Operatore
	, @Id_xMOTRRig_P			int						-- Identificativo P per proporre Ubicazione in T
	, @Quantita					numeric(18,8)			-- Quantità da stoccare
	, @Cd_MG_A					char(5)					-- Magazzino in cui stoccare
	, @Cd_MGUbicazione_Escludi	varchar(20) output
	, @Cd_MGUbicazione			varchar(20) output		-- Valore di ritorno: Ubicazione in cui stoccare l'articolo
	, @QtaAssgnabile			numeric(18,8) output	-- Valore di ritorno: quantità assegnabile all'ubicazione trovata
)
/*ENCRYPTED*/
as begin
	-- Tabella di appoggio per la ricerca delle ubicazioni
	declare @out table (
		Ordinamento				smallint					-- L'ordinamento è impostato per corsia/ubicazione. L'ordinamento per corsia è necessario per proporre in modo ottimizzato il giro che l'operatore deve fare per stoccare la merce
		, Cd_MGUbicazione		varchar(20)					-- Codice ubicazione in cui poter stoccare l'articolo
		, ScortaDisp			numeric(18,8) default 0		-- Quantità di merce accoglibile dall'ubicazione
		, PesoDisp				numeric(18,8) default 0		-- Peso accoglibile dall'ubicazione
		, VolumeDisp			numeric(18,8) default 0		-- Volume accoglibile dall'ubicazione
		, Giacenza				numeric(18,8) default 0		-- Quantità di merce già stoccata nell'ubicazione, utilizzato per proporre un'ubicazione vuota nel caso non si trovasse spazio cercando per peso, volume o scorta
	)

	-- Gestione esclusioni
	if isnull(@Cd_MGUbicazione_Escludi, '') <> '' begin 

		-- Esclude l'ubicazione passata alla sp se non presente
		declare @e varchar(max)

		-- Recupera l'xml delle esclusioni
		select @e = cast(Esclusioni as varchar(max)) from xMOTRRig_P where Id_xMOTRRig_P = @Id_xMOTRRig_P
		-- Normalizzo il valore selezionato
		set @e = case when isnull(@e, '<rows/>') = '<rows/>' then '<rows></rows>' else @e end

		-- Verifica la presenza dell'esclusione
		if charindex('<row cd_mgubicazione="' + @Cd_MGUbicazione_Escludi + '"/>', @e) = 0
			-- non presente la aggiunge
			set @e = replace(@e, '</rows>', '<row cd_mgubicazione="' + ltrim(rtrim(@Cd_MGUbicazione_Escludi)) + '"/></rows>')

		-- Aggiorno le esclusioni 
		update xMOTRRig_P set Esclusioni = @e where Id_xMOTRRig_P = @Id_xMOTRRig_P

	end

	-- Restituisce la nuova ubicazione
	declare @RC int

	execute @RC = [dbo].[xmosp_xMOTRRig_T_RicercaUbicazione] 
					@Terminale
				  , @Cd_Operatore
				  , @Id_xMOTRRig_P
				  , @Quantita
				  , @Cd_MG_A
				  , @Cd_MGUbicazione output
				  , @QtaAssgnabile output

	return @RC

end
go

-- Salva le righe in T assegnandogli le ubicazioni e l'ordine in modo da rendere ottmizzato il giro
create procedure xmosp_xMOTRRig_T_Save (
	@Terminale			varchar(20)		-- Terminale
	, @Cd_Operatore		varchar(20)		-- Operatore
	, @Mode				smallint		-- 0=ScortaMax, 1=PesoMax, 2=VolumeMax
	, @Id_xMOTR			int				-- ID del trasferimento da elaborare
)
/*ENCRYPTED*/
as begin

	declare @r int = 1;

	declare @Cd_MG_A				char(5)				-- Magazzino in cui stoccare la merce
	-- Recuperato dalla testa del documento il magazzino di arrivo
	set @Cd_MG_A = (select Cd_MG_A from xMOTR where Id_xMOTR = @Id_xMOTR)

	-- Variabili utilizzate nel ciclo
	declare @Cd_MGUbicazione_A		varchar(20)			-- Ubicazione in cui stoccare l'articolo
	declare @QtaAssegnabile			numeric(18,8)		-- Quantità da stoccare nell'ubicazione trovata

	-- Variabili utilizzate dal cursore
	declare @Id_xMOTRRig_P			int					-- Id della riga padre
			, @Quantita				numeric(18,8)		-- Quantità da stoccare

	-- Recupero le righe presenti in xMOTRRig_P che hanno un residuo da inserire in xMOTRRig_T per l'Id_xMOTR passato
	declare trp_to_trt cursor for
	select 
		Id_xMOTRRig_P
		, Quantita
	from (
		select
			Id_xMOTRRig_P		= xMOTRRig_P.Id_xMOTRRig_P
								-- Quantità è pari a quella di partenza meno quella totale proposta non ubicata
			, Quantita			= xMOTRRig_P.Quantita - isnull(xMOTRRig_T.QtaUMP, 0)
								-- Ordina per primi gli articoli che hanno ubicazioni fisse
			, Ub_Fisse			= case when ar_con_ub.Cd_AR is null then 1 else 0 end
		from 
			xMOTRRig_P
				left join (
					-- Recupero dalle righe temporanee la sommatoria della quantità già prenotata/stoccata per ogni articolo
					select
						Id_xMOTRRig_P		= xMOTRRig_T.Id_xMOTRRig_P
						, QtaUMP			= sum(xMOTRRig_T.QtaUMP)
					from 
						xMOTRRig_T
					where
							Id_xMOTR = @Id_xMOTR
					group by
						Id_xMOTRRig_P
				) xMOTRRig_T			on xMOTRRig_P.Id_xMOTRRig_P	= xMOTRRig_T.Id_xMOTRRig_P
			left join (select distinct Cd_AR from ARMGUbicazione) as ar_con_ub on xMOTRRig_P.Cd_AR = ar_con_ub.Cd_AR
		where
				xMOTRRig_P.Id_xMOTR = @Id_xMOTR
	) as PeT
	where
		Quantita > 0
	order by 
		Ub_Fisse
	open trp_to_trt
	fetch next from trp_to_trt into @Id_xMOTRRig_P, @Quantita
	while @@FETCH_STATUS = 0 begin
		-- Ciclo solo se ho quantità ancora da assegnare e se sono riuscito ad ubicare l'articolo
		-- In questo modo assegno completamente un'articolo prima di passare al successivo
		while @Quantita > 0 begin
			-- Resetto le variabili di ritorno
			set @QtaAssegnabile = null
			set @Cd_MGUbicazione_A = null

			-- Cerco la prima ubicazione libera
			exec xmosp_xMOTRRig_T_RicercaUbicazione @Terminale, @Cd_Operatore, @Id_xMOTRRig_P, @Quantita, @Cd_MG_A, @Cd_MGUbicazione_A output, @QtaAssegnabile output
			
			-- Se la funzione di ricerca mi restituisce 0 come quantità significa che
			-- non posso proporre nulla all'operatore, quindi imposto come NON UBICABILE l'intera quantità
			if (isnull(@QtaAssegnabile, 0) = 0) 
				-- La quantità non è ubicabile quindi inserisco l'intera quantità
				set @QtaAssegnabile = @Quantita 
			
			-- Inserisco la riga in xMOTRRig_T
			insert into xMOTRRig_T(Id_xMOTR, Id_xMOTRRig_P, QtaUMP, Cd_MG_A, Cd_MGUbicazione_A)
			select 
				@Id_xMOTR
				, @Id_xMOTRRig_P
				, @QtaAssegnabile	-- Se non ubicabile sarà pari al totale
				, @Cd_MG_A
				, @Cd_MGUbicazione_A

			-- Verifico se ho un residuo da assegnare
			set @Quantita = @Quantita - @QtaAssegnabile
		end
		-- Passo all'articolo successivo
		fetch next from trp_to_trt into @Id_xMOTRRig_P, @Quantita
	end
	close trp_to_trt
	deallocate trp_to_trt

	exitsp:
		select 
			Result = @r

	return @r
end
go

-- Inserisce un articolo alla lista di stoccaggio
create procedure xmosp_xMOTRRig_P_AddAR(
	@Terminale varchar(39)
	, @Cd_Operatore varchar(20)
	, @Id_xMOTR int
	, @Cd_AR	varchar(20)
	, @Quantita	numeric(18,8)
	, @Cd_ARMisura	char(2)
	, @Cd_MG_P char(5)
	, @Cd_MGUbicazione_P varchar(20)
)
/*ENCRYPTED*/
as begin
	
	declare @r int
	declare @m varchar(max)
	
	
	Begin try 

		if(ISNULL(@Id_xMOTR, 0) = 0) begin
			set @r = -10; set @m = 'Errore: valore mancante per il parametro xMOTR!'; goto exitsp;
		end

		if(ISNULL(@Cd_MG_P, '') = '') begin
			set @r = -20; set @m = 'Errore: nessun magazzino di partenza selezionato.'; goto exitsp;
		end

		if(ISNULL(@Cd_AR, '') = '') begin
			set @r = -30; set @m = 'Errore: nessun codice articolo selezionato.'; goto exitsp;
		end

		if(ISNULL(@Cd_ARMisura, '') = '') begin
			set @r = -40; set @m = 'Errore: nessuna unità di misura specificata per l''articolo.'; goto exitsp;
		end

		set @Cd_MGUbicazione_P = case when isnull(@Cd_MGUbicazione_P, '') = '' then null else @Cd_MGUbicazione_P end
		
		exec xmosp_xMOTRRig_P_Save @Terminale, @Cd_Operatore, @Id_xMOTR, @Cd_AR, '', @Quantita, @Cd_ARMisura, @Cd_MG_P, @Cd_MGUbicazione_P, null

		exec xmosp_xMOTRRig_T_Save @Terminale, @Cd_Operatore, 0, @Id_xMOTR

		set @r = 1; set @m = 'Articolo aggiunto con successo';

	End Try

	Begin catch 
		set @r = abs(ERROR_NUMBER()) * -1; set @m = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	End Catch

	exitsp:
		select 
			Result = @r
			, Messaggio = @m	
	return @r

end
go

Create procedure xmosp_xMOPRTR_Save(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Id_PrBLAttivita		int
	, @Cd_PrRisorsa			varchar(20)				-- Risorsa a cui si stanno portando i materiali (per ora non modificabile)
	, @Note					varchar(1000)
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_xMOPRTR			int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	declare @trn bit = 0
	begin try

		if @@TRANCOUNT = 0 begin
			begin transaction 
			set @trn = 1
		end

			if(ISNULL(@Id_PrBLAttivita, 0) = 0) begin
				set @r = -10; set @msgout = 'Errore: id attività della Bolla non selezionato (Id_PrBLAttivita)!'; goto exitsp;
			end

			if isnull(@Cd_PrRisorsa, '') = ''		set @Cd_PrRisorsa = (select Cd_PrRisorsa from PRBL where Id_PrBL = (select Id_PrBL from PRBLAttivita Where Id_PrBLAttivita = @Id_PrBLAttivita))
			if isnull(@Note, '') = ''				set @Note = null;

			-- Cerca se esiste un movimento aperto per l'attività della bolla lo aggiorna senza aggiungerlo
			select
				@Id_xMOPRTR = Id_xMOPRTR
			from
				xMOPRTR
			where
					Id_PrBLAttivita	= @Id_PrBLAttivita
				and Stato = 0 -- In compilazione

			if @Id_xMOPRTR is null begin
				-- Salva la testa in xMOPRTR
				insert into xMOPRTR (Terminale, Cd_Operatore, Id_PrBLAttivita, Data, Cd_PrRisorsa, Note)
				values (@Terminale, @Cd_Operatore, @Id_PrBLAttivita, getdate(), @Cd_PrRisorsa, @Note)
				-- Memorizzo l'Id del record
				set @Id_xMOPRTR = @@IDENTITY
			end else begin
				update xMOPRTR set 
					Note = @Note
				where
					Id_xMOPRTR = @Id_xMOPRTR
			end

			set @r = 1
		
		if @trn = 1 commit transaction;

	end try
	begin catch
		if @trn = 1 And @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r
end 
go

Create procedure xmosp_xMOPRTR_Close(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)	
	, @Id_PrBLAttivita		int
	, @PercTrasferita		numeric(18, 2)
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_PrTrAttivita		int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 

			-- Recupera l'id di testa da trasferire
			declare @Id_xMOPRTR int
			set @Id_xMOPRTR = (select Id_xMOPRTR from xMOPRTR where Id_PrBLAttivita = @Id_PrBLAttivita And Stato = 0) -- In compilazione

			if @Id_xMOPRTR = 0 begin
				set @r = -10; set @msgout = 'Errore: impossibile recuperare il trasferimento temporaneo per l''attività!!'; goto exitsp;
			end

			declare @Qta_Prodotta numeric(18,8)
			declare @Qta_DaProdurre numeric(18, 8)
			declare @Quantita numeric(18, 8)

			if @PercTrasferita = 0 begin
				-- Anche se non ho trasfertito nulla devo trasferire almeno quantità per 1 pezzo
				set @Quantita = 1
			end else begin
				-- Quantità da produrre
				set @Qta_DaProdurre = (select Quantita from PRBLAttivita where Id_PrBLAttivita = @Id_PRBLAttivita)
				-- Calcola la quantità trasferita del padre
				set @Qta_Prodotta = isnull((select sum(Quantita) from PRTRAttivita where Id_PrBLAttivita = @Id_PrBLAttivita), 0)
				-- Calcola la quantità producibile con questo trasferimento
				-- Se minore di 1: 1
				set @Quantita = (@Qta_DaProdurre * @PercTrasferita / 100) - @Qta_Prodotta
				if @Quantita < 1 
					set @Quantita = 1
			end

			-- Salva la testa in PRTRAttivita
			-- Attenzione per default inserisce 1 come quantità del padre in quanto ci sono CK che ne impediscono il salvataggio
			insert into PRTRAttivita (Id_PrBLAttivita, Id_DoTes_DDT, UltimoTR, Data, Cd_PrRisorsa, Quantita, NotePrTRAttivita)
			select top 1 
				Id_PrBLAttivita	= @Id_PrBLAttivita
				, Id_DoTes_DDT	= null
				, UltimoTR		= case when @PercTrasferita >= 100 then 1 else 0 end
				, Data			= getdate()
				, Cd_PrRisorsa	= PRBL.Cd_PrRisorsa
				, Quantita		= @Quantita
				, NotePrTRAttivita= null
			from 
				xMOPRTR 
					inner join PRBLAttivita on xMOPRTR.Id_PrBLAttivita = PrBLAttivita.Id_PrBLAttivita
					inner join PRBL on PrBLAttivita.Id_PrBL = PrBl.Id_PrBL
			where 
					xMOPRTR.Id_PrBLAttivita = @Id_PrBLAttivita
				And Stato = 0  -- In compilazione
			
			-- Memorizzo l'Id del record
			set @Id_PRTRAttivita = @@IDENTITY

			if @Id_PRTRAttivita = 0 begin
				set @r = -20; set @msgout = 'Errore: impossibile creare il trasferimento dell''attività!!'; goto exitsp;
			end

			-- Completa i dati di testa
			update xMOPRTR set
				Id_PRTRAttivita = @Id_PrTrAttivita
				, Stato = 2 -- Chiusa
			where
				Id_xMOPRTR = @Id_xMOPRTR

			-- Recupera i dati di magazzino di arrivo
			declare @Cd_MG_A				varchar(5)			-- Magazzino di destinazione
			declare @Cd_MGUbicazione_A	varchar(20)				-- Ubicazione di destinazione

			select 
				@Cd_MG_A				= isnull(xMOLinea.Cd_MG, PRRisorsa.Cd_MG_L)
				, @Cd_MGUbicazione_A	= xMOLinea.Cd_MGUbicazione
			from
				PRRisorsa
					left join xMOLinea on PRRisorsa.xCd_xMOLinea = xMOLinea.Cd_xMOLinea
			where
				PRRisorsa.Cd_PrRisorsa = (select Cd_PrRisorsa from PRBL where Id_PrBL = (select Id_PrBL from PRBLAttivita Where Id_PrBLAttivita = @Id_PrBLAttivita))
					

			-- Salva le righe in PRTRMateriale
			insert into PRTRMateriale (
					Id_PRTRAttivita, Tipo, Id_PrOLAttivita, Cd_AR
					, Consumo, Cd_ARMisura, FattoreToUM1, ValoreUnitario
					, Cd_MG_P, Cd_MGUbicazione_P, Cd_MG_A, Cd_MGUbicazione_A
					, Cd_ARLotto, NotePRTRMateriale, Sequenza, xId_PrBLMateriale
					, xTerminale, xCd_Operatore, xMancante
				)
			select
				@Id_PRTRAttivita, 2, null, PRBLMateriale.Cd_AR
				, xMOPRTRRig.Quantita, xMOPRTRRig.Cd_ARMisura, xMOPRTRRig.FattoreToUM1, 0
				, xMOPRTRRig.Cd_MG_P, xMOPRTRRig.Cd_MGUbicazione_P, @Cd_MG_A, @Cd_MGUbicazione_A
				, xMOPRTRRig.Cd_ARLotto, xMOPRTRRig.Note, isnull((select max(Sequenza) from PRTRMateriale where Id_PRTRAttivita = @Id_PRTRAttivita), 0) + 1, xMOPRTRRig.Id_PrBLMateriale
				, xMOPRTRRig.Terminale, xMOPRTRRig.Cd_Operatore, xMOPRTRRig.Mancante
			from
				xMOPRTRRig
					inner join PRBLMateriale on xMOPRTRRig.Id_PrBLMateriale = PRBLMateriale.Id_PrBLMateriale
			where
				xMOPRTRRig.Id_xMOPRTR = @Id_xMOPRTR


			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r	

end 
go

create procedure xmosp_xMOPRTRRig_Save(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)	
	, @Id_PrBLAttivita		int
	, @Id_PrBLMateriale		int
	, @Cd_ARLotto			varchar(20)				-- lotto articolo movimentato
	, @Quantita				numeric(18,8)			-- quantita del articolo
	, @Cd_ARMisura			char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @FattoreToUM1			numeric(18, 8)
	, @Cd_MG_P				varchar(5)				-- Magazzino di partenza 
	, @Cd_MGUbicazione_P	varchar(20)				-- Ubicazione di destinazione 
	, @Mancante				bit						-- vero se l'operatore vuole segnalare una anomalia sul materiale
	, @Note					varchar(1000)
	, @msgout				varchar(max)	output	-- Messaggio
	, @Id_xMOPRTR			int				output	-- Id creato/selezionato
	, @Id_xMOPRTRRig		int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 

			-- Salva/Carica l'id di testa
			exec @r = xmosp_xMOPRTR_Save @Terminale, @Cd_Operatore, @Id_PrBLAttivita, null, null, @msgout, @Id_xMOPRTR output

			if(ISNULL(@Id_xMOPRTR, 0) = 0) begin
				set @r = -10; set @msgout = 'Errore: id xMOPRTR non selezionato (Id_xMOPRTR)!!'; goto exitsp;
			end

			if(ISNULL(@Id_PrBLMateriale, 0) = 0) begin
				set @r = -20; set @msgout = 'Errore: id materiale dell''attività della Bolla non selezionato (Id_PrBLMateriale)!!'; goto exitsp;
			end

			if(ISNULL(@Cd_MG_P, '') = '') begin
				set @r = -30; set @msgout = 'Errore: Magazzino di partenza errato o mancante!!'; goto exitsp;
			end

			if isnull(@Cd_MGUbicazione_P, '') = ''	set @Cd_MGUbicazione_P = null;
			if isnull(@Cd_ARLotto, '') = ''			set @Cd_ARLotto = null;
			if isnull(@Note, '') = ''				set @Note = null;

			-- Salva la riga in PRTRMateriale
			insert into xMOPRTRRig (Id_xMOPRTR, Terminale, Cd_Operatore, Id_PrBLMateriale
									, Cd_AR, Cd_ARLotto, Quantita, DataOra
									, Cd_ARMisura, FattoreToUM1, Cd_MG_P, Cd_MGUbicazione_P
									, Mancante, Note)
			select
				@Id_xMOPRTR, @Terminale, @Cd_Operatore, @Id_PrBLMateriale
				, Cd_AR, @Cd_ARLotto, @Quantita, getdate()
				, @Cd_ARMisura, @FattoreToUM1, @Cd_MG_P, @Cd_MGUbicazione_P
				, @Mancante, @Note
			from
				PRBLMateriale
			where
				Id_PrBLMateriale = @Id_PrBLMateriale

			set @Id_xMOPRTRRig = @@IDENTITY

			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r
end 
go

-- Cancella i trasferimenti dei materiali dell'articolo
create procedure xmosp_xMOPRTRRig_Delete(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)	
	, @Id_PrBLAttivita		int
	, @Id_PrBLMateriale		int
	, @msgout				varchar(max)	output	-- Messaggio
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 

			delete from xMOPRTRRig
			where
					Id_xMOPRTR In (select Id_xMOPRTR from xMOPRTR  where Id_PrBLAttivita = @Id_PrBLAttivita And Stato = 0)
				And Id_PrBLMateriale = @Id_PrBLMateriale

			-- cancella eventuali teste orfane
			delete from xMOPRTR 
			where 
					Id_PrBLAttivita = @Id_PrBLAttivita 
				And Stato = 0
				And Id_xMOPRTR not in (select Id_xMOPRTR from xMOPRTRRig)

			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Eliminazione effettuata con sucesso.')
	return @r
end 
go

create procedure xmosp_xMOPRTRMateriale_Save(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Cd_PrRisorsa			varchar(20)				-- Risorsa a cui si stanno portando i materiali
	, @Id_PrBLAttivita		int
	, @Id_PrBLMateriale		int
	, @Cd_ARLotto			varchar(20)				-- lotto articolo movimentato
	, @Quantita				numeric(18,8)			-- quantita del articolo
	, @Cd_ARMisura			char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @FattoreToUM1			numeric(18, 8)
	, @Cd_MG_P				varchar(5)				-- Magazzino di partenza (se nullo prende quello del materiale)
	, @Cd_MGUbicazione_P	varchar(20)				-- Ubicazione di destinazione (se nulla prende quello del materiale)
	, @Cd_MG_A				varchar(5)				-- Magazzino di destinazione
	, @Cd_MGUbicazione_A	varchar(20)				-- Ubicazione di destinazione
	, @Note					varchar(1000)
	, @Mancante				bit						-- vero se l'operatore vuole segnalare una anomalia sul materiale
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_PRTRAttivita		int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 

			if isnull(@Cd_MG_P, '') = ''			set @Cd_MG_P = null;
			if isnull(@Cd_MGUbicazione_P, '') = ''	set @Cd_MGUbicazione_P = null;
			if isnull(@Cd_ARLotto, '') = ''			set @Cd_ARLotto = null;
			if isnull(@Cd_MGUbicazione_A, '') = ''	set @Cd_MGUbicazione_A = null;
			if isnull(@Note, '') = ''				set @Note = null;

			-- Cerca il PRTRAttivita del Id_PrBLAttivita del giorno nella stessa risorsa: se lo trovo vado in append di PRTRMateriale
			select
				@Id_PRTRAttivita = Id_PrTRAttivita
			from
				PRTRAttivita
			where
					Id_PrBLAttivita	= @Id_PrBLAttivita
				and cast(Data as date) = cast(getdate() as date)

			if @Id_PRTRAttivita is null begin
				-- Salva la testa in PRTRAttivita
				-- Attenzione per default inserisce 1 come quantità del padre in quanto ci sono CK che ne impediscono il salvataggio
				insert into PRTRAttivita (Id_PrBLAttivita, Id_DoTes_DDT, UltimoTR, Data, Cd_PrRisorsa, Quantita, NotePrTRAttivita)
				select @Id_PrBLAttivita, null, 0, getdate(), @Cd_PrRisorsa, 1, null
				from PRRisorsa
				where 
					Cd_PrRisorsa = @Cd_PrRisorsa
				-- Memorizzo l'Id del record
				set @Id_PRTRAttivita = @@IDENTITY
			end


			-- Salva la riga in PRTRMateriale
			insert into PRTRMateriale (
					Id_PRTRAttivita, Tipo, Id_PrOLAttivita, Cd_AR
					, Consumo, Cd_ARMisura, FattoreToUM1, ValoreUnitario
					, Cd_MG_P, Cd_MGUbicazione_P, Cd_MG_A, Cd_MGUbicazione_A
					, Cd_ARLotto, NotePRTRMateriale, Sequenza, xId_PrBLMateriale
					, xTerminale, xCd_Operatore, xMancante
				)
			select
				@Id_PRTRAttivita, 2, null, Cd_AR
				, @Quantita, @Cd_ARMisura, @FattoreToUM1, 0
				, isnull(@Cd_MG_P, Cd_MG), isnull(@Cd_MGUbicazione_P, Cd_MGUbicazione), @Cd_MG_A, @Cd_MGUbicazione_A
				, @Cd_ARLotto, @Note, isnull((select max(Sequenza) from PRTRMateriale where Id_PRTRAttivita = @Id_PRTRAttivita), 0) + 1, @Id_PrBLMateriale
				, @Terminale, @Cd_Operatore, @Mancante
			from
				PRBLMateriale
			where
				Id_PrBLMateriale = @Id_PrBLMateriale

			-- Calcola in base alla percentuale di materiale dichiarato nel trasferimento odierno corrente
			declare @Qta_P numeric(18, 8)
			declare @Qta_T numeric(18, 8)
			-- Quantità da produrre
			set @Qta_P = (select Qta_P = Quantita from PRBLAttivita where Id_PrBLAttivita = @Id_PRBLAttivita)
			-- Seleziona la minima quantità producibile
			select
				@Qta_T = isnull(min(p.Qta), -1)
			from (
				select 
					prblm.Cd_AR
					-- Calcola la producibilità del padre (-1 non è stata portata quantità per produrre il padre)
					-- il calcolo: P producibile = Qta MP TRA / (Qta MP Tot / Qta da Produrre)
					, Qta = case when isnull(prtrm.Qta_T, 0) = 0 then -1 else prtrm.Qta_T / (prblm.Qta_M / @Qta_P) end
				from
					(
						-- Totale materiale da utilizzare
						select Cd_AR, Qta_M = sum(Consumo * FattoreToUm1) from PRBLMateriale where Id_PRBLAttivita = @Id_PRBLAttivita And Tipo = 2 And Consumo > 0 group by Cd_AR
					) as prblm
					left join 
					(
						-- Totale materiale trasferito
						select Cd_AR, Qta_T = sum(Consumo * FattoreToUm1) from PRTRMateriale where Id_PRTRAttivita = @Id_PRTRAttivita And Tipo = 2 And Consumo > 0 group by Cd_AR
					) as prtrm on prblm.Cd_AR = prtrm.Cd_AR
				) as p

			-- Arrotonda all'intero inferiore
			set @Qta_T = cast(cast(@Qta_T as int) as numeric(18, 8))
			
			-- Aggiorna la quantità producibile del padre solo se ho prodotto di più
			update PRTRAttivita set 
				Quantita = @Qta_T -- La Qta prodotta del padre viene aggiornata solo del trasfertimento corrente
			where 
					Id_PRTRAttivita = @Id_PRTRAttivita
				And @Qta_T > 0
				And @Qta_T > Quantita

			-- Ri-Calcola la quantità totale trasferita
			set @Qta_T = isnull((select sum(Quantita) from PRTRAttivita Where Id_PrBLAttivita = @Id_PrBLAttivita), 0)

			-- Se non esiste un UltimoTr e ho trasferito a sufficienza imposto UltimoTr alla rilevazione corrente
			if  @Qta_T >= @Qta_P And not exists(select * from PRTRAttivita Where Id_PrBLAttivita = @Id_PrBLAttivita And UltimoTR = 1) begin
				update PRTRAttivita set
					UltimoTR = 1
				where 
					Id_PRTRAttivita = @Id_PRTRAttivita
			end

			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r
end 
go

create procedure xmosp_xMOPRTRMateriale_Back( 
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Cd_MG_P				char(5)					
	, @Cd_MGUbicazione_P	varchar(20)				
	, @Cd_AR				varchar(20)				-- articolo 
	, @Cd_ARLotto			varchar(20)				-- lotto 
	, @Quantita_P			numeric(18,8)			-- quantita del articolo di partenza
	, @Quantita_A			numeric(18,8)			-- quantita del articolo di arrivo
	, @Cd_ARMisura			char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @FattoreToUM1			numeric(18, 8)
	, @Note					varchar(1000)
	, @Cd_MG_A				varchar(5)				-- Magazzino di destinazione
	, @Cd_MGUbicazione_A	varchar(20)				-- Ubicazione di destinazione
	, @xMOCompleta			bit						-- Ubicazione di arrivo completa
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_MgMovInt			int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 
			-- Trasferisce dal magazzino produzione al magazzino MP

			if isnull(@Cd_MGUbicazione_P, '') = '' set @Cd_MGUbicazione_P = null;
			if isnull(@Cd_MGUbicazione_A, '') = '' set @Cd_MGUbicazione_A = null;

			Insert Into MgMovInt (DataMov, Descrizione) 
			values (getdate(), 'Rientro Prod.')
	
			-- Recupere l'Id di testa generato
			Select  @Id_MgMovInt = Scope_Identity()

			if (isnull(@Id_MgMovInt, 0) = 0) begin
				set @r = -100; set @msgout = 'Impossibile generare il movimento di testa di MGMovInt!!'; goto exitsp;
			end

			-- Recupera le descrizioni
			declare @Id_DesCar tinyint, @Id_DesSca tinyint
			select  @Id_DesCar = MI_Id_MGMovDes_CAR, @Id_DesSca = MI_Id_MGMovDes_SCA from BLSSettings

			if @Quantita_A > 0 begin
			-- Inserisco le righe di partenza
				Insert Into MgMov (
					Id_MgMovInt, Cd_AR, Cd_MG, Cd_MGUbicazione,
					Cd_ARLotto, Cd_DoSottoCommessa, PadreComponente, Cd_MGEsercizio,
					DataMov, Id_MGMovDes, Quantita, PartenzaArrivo,
					Valore, CarT, ScaT
				)
				--- @Cd_DOSottoCommessa
				values(
					@Id_MGMovInt, @Cd_Ar, @Cd_MG_P, @Cd_MGUbicazione_P
					, @Cd_ARLotto, null, 'P', dbo.afn_MGEsercizio(getdate())
					, getdate(), @Id_DesSca, round(@Quantita_A * @FattoreToUM1, (Select DecimaliQta From Preferenza)), 'P'
					, 0, 0, 1
				)
			end

			set @r = @@ROWCOUNT
			if @r < 1 begin 
				set @r = -30; set @msgout = 'Errore nel salvataggio delle righe di partenza del movimento'; goto exitsp;
			end
		
			-- Inserisco le righe di arrivo
			Insert Into MgMov (
					Id_MgMovInt, Cd_AR, Cd_MG, Cd_MGUbicazione,
					Cd_ARLotto, Cd_DoSottoCommessa, PadreComponente, Cd_MGEsercizio,
					DataMov, Id_MGMovDes, Quantita, PartenzaArrivo,
					Valore, CarT, ScaT
			)
			-- @Cd_DOSottoCommessa
			values(
				@Id_MGMovInt, @Cd_Ar, @Cd_MG_A, @Cd_MGUbicazione_A
				, @Cd_ARLotto, null, 'P', dbo.afn_MGEsercizio(getdate())
				, getdate(), @Id_DesCar, round(@Quantita_A * @FattoreToUM1, (Select DecimaliQta From Preferenza)), 'A'				
				, 0, 1, 0
			)
		
			set @r = @@ROWCOUNT
			if @r < 1 begin 
				set @r = -40; set @msgout = 'Errore nel salvataggio delle righe di arrivo del movimento'; goto exitsp;
			end

			-- Rimuove il Completa dall'ubicazione di partenza
			update MGUbicazione set
				xMOCompleta = @xMOCompleta
			where
					Cd_MG = @Cd_MG_A
				And Cd_MGUbicazione = @Cd_MGUbicazione_A

			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r
end 
go

create procedure xmosp_xMOPRTRMateriale_Drop(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Cd_MG_P				char(5)					
	, @Cd_MGUbicazione_P	varchar(20)				
	, @Cd_AR				varchar(20)				-- articolo 
	, @Cd_ARLotto			varchar(20)				-- lotto 
	, @Quantita_P			numeric(18,8)			-- quantita del articolo di partenza
	, @Quantita_A			numeric(18,8)			-- quantita del articolo di arrivo
	, @Cd_ARMisura			char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @FattoreToUM1			numeric(18, 8)
	, @Note					varchar(1000)
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_MgMovInt			int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try

		begin transaction 
			-- Trasferisce dal magazzino produzione al magazzino MP

			Insert Into MgMovInt (DataMov, Descrizione) 
			values (getdate(), 'Rett. Qta. Prod.')
	
			-- Recupere l'Id di testa generato
			Select  @Id_MgMovInt = Scope_Identity()

			if (isnull(@Id_MgMovInt, 0) = 0) begin
				set @r = -100; set @msgout = 'Impossibile generare il movimento di testa di MGMovInt!!'; goto exitsp;
			end

			-- Recupera le descrizioni
			declare @Id_DesCar tinyint, @Id_DesSca tinyint
			select  @Id_DesCar = MI_Id_MGMovDes_CAR, @Id_DesSca = MI_Id_MGMovDes_SCA from BLSSettings

			if (@Quantita_P - @Quantita_A) > 0 begin
				-- Scarica la differenza di quantità
				Insert Into MgMov (
					Id_MgMovInt, Cd_AR, Cd_MG, Cd_MGUbicazione,
					Cd_ARLotto, Cd_DoSottoCommessa, PadreComponente, Cd_MGEsercizio,
					DataMov, Id_MGMovDes, Quantita, PartenzaArrivo,
					Valore, CarT, ScaT
				)
				--- @Cd_DOSottoCommessa
				values(
					@Id_MGMovInt, @Cd_Ar, @Cd_MG_P, @Cd_MGUbicazione_P
					, @Cd_ARLotto, null, 'P', dbo.afn_MGEsercizio(getdate())
					, getdate(), @Id_DesSca, round((@Quantita_P - @Quantita_A) * @FattoreToUM1, (Select DecimaliQta From Preferenza)), 'P'
					, 0, 0, 1
				)
			end

			set @r = @@ROWCOUNT
			if @r < 1 begin 
				set @r = -40; set @msgout = 'Errore nel salvataggio delle righe di arrivo del movimento'; goto exitsp;
			end

			set @r = 1
		
		commit transaction;

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Salvataggio effettuato con sucesso.')
	return @r
end 
go

create procedure xmosp_xMOPRTRMateriale_ToBL(
	@Terminale				varchar(39)		
	, @Cd_Operatore			varchar(20)		
	, @Cd_PrRisorsa			varchar(20)				-- Risorsa a cui si stanno portando i materiali
	, @Cd_MG_P				char(5)
	, @Cd_MGUbicazione_P	varchar(20)
	, @Quantita_P			numeric(18,8)			-- quantita del articolo di partenza
	, @Cd_ARLotto			varchar(20)				-- lotto 
	, @Cd_ARMisura			char(2)					-- unita misura dell'articolo; controllato tramite un checkbox
	, @FattoreToUM1			numeric(18, 8)
	, @Id_PrBLAttivita_A	int						-- Fase della Bolla di arrivo (se nullo)
	, @Id_PrBLMateriale_A	int						-- Materiale di destinazione
	, @Quantita_A			numeric(18,8)			-- quantita del articolo di arrivo
	, @Note					varchar(1000)
	, @msgout				varchar(max)	output	-- Messaggio 
	, @Id_PRTRAttivita		int				output	-- Id creato
) 
/*ENCRYPTED*/
as begin	

	declare @r int = 0
	begin try
		
		-- Se il materiale è destinato ad una bolla lo carica
		if isnull(@Id_PrBLAttivita_A, 0) > 0 And isnull(@Id_PrBLMateriale_A, 0) > 0 begin

			declare @Cd_MG_A			char(5) 		
			declare @Cd_MGUbicazione_A	varchar(20) 	

			-- Recupera i magazzini di arrivo dalla linea di produzione
			select @Cd_MG_A = Cd_MG, @Cd_MGUbicazione_A = Cd_MGUbicazione from xMOLinea where Cd_xMOLinea = (select xCd_xMOLinea from PRRisorsa where Cd_PrRisorsa = isnull(@Cd_PrRisorsa, ''))

			if isnull(@Cd_MG_A, '') = '' begin
				set @r = -100; set @msgout = 'Impossibile recuperare il magazzino di arrivo della risorsa [' + isnull(@Cd_PrRisorsa, '') + ']!!'; goto exitsp;
			end
				
			exec @r = xmosp_xMOPRTRMateriale_Save @Terminale				
												, @Cd_Operatore			
												, @Cd_PrRisorsa			
												, @Id_PrBLAttivita_A		
												, @Id_PrBLMateriale_A		
												, @Cd_ARLotto			
												, @Quantita_A				
												, @Cd_ARMisura			
												, @FattoreToUM1			
												, @Cd_MG_P				
												, @Cd_MGUbicazione_P	
												, @Cd_MG_A				
												, @Cd_MGUbicazione_A	
												, @Note					
												, 0 					-- Mancante				
												, @msgout				output
												, @Id_PRTRAttivita		output
			
			if @r < 0 begin
				goto exitsp;
			end

		end

		set @r = 1

	end try
	begin catch
		if @@TRANCOUNT > 0 rollback transaction;
		set @r = abs(ERROR_NUMBER()) * -1; set @msgout = cast(ERROR_MESSAGE() as varchar(max)); goto exitsp;
	end catch
	
exitsp:
	set @msgout = isnull(@msgout, 'Trasferimento a BL effettuato con successo.')
	return @r
end 
go

create procedure xmosp_xMOMGUbicazione_Ricerca (
	@Terminale			varchar(20)				-- Terminale
	, @Cd_Operatore		varchar(20)				-- Operatore
	, @Cd_AR			varchar(20)				-- Codice articolo
	, @Quantita			numeric(18,8)			-- Quantità da stoccare
	, @Cd_MG			char(5)					-- Magazzino in cercare l'ubicazione
	, @Cd_MGUbicazione	varchar(20) output		-- Valore di ritorno: Ubicazione in cui stoccare l'articolo
	, @QtaAssgnabile	numeric(18,8) output	-- Valore di ritorno: quantità assegnabile all'ubicazione trovata
	, @Esclusioni		xml	output				-- Ubicazioni escluse dall'operatore. Es.: '<rows><row>00001.A.C01.R02</row><row>00001.A.C01.R03</row></rows>'
) 
/*ENCRYPTED*/
as begin
	-- Tabella di appoggio per la ricerca delle ubicazioni
	declare @out table (
		Ordinamento				smallint					-- L'ordinamento è impostato per corsia/ubicazione. L'ordinamento per corsia è necessario per proporre in modo ottimizzato il giro che l'operatore deve fare per stoccare la merce
		, Cd_MGUbicazione		varchar(20)					-- Codice ubicazione in cui poter stoccare l'articolo
		, ScortaDisp			numeric(18,8) default 0		-- Quantità di merce accoglibile dall'ubicazione
		, PesoDisp				numeric(18,8) default 0		-- Peso accoglibile dall'ubicazione
		, VolumeDisp			numeric(18,8) default 0		-- Volume accoglibile dall'ubicazione
		, Giacenza				numeric(18,8) default 0		-- Quantità di merce già stoccata nell'ubicazione, utilizzato per proporre un'ubicazione vuota nel caso non si trovasse spazio cercando per peso, volume o scorta
	)

	-- Se esistono delle ubicazioni specifiche per l'articolo da stoccare cerco una disponibilità solo fra di esse
	if exists(select Cd_MGUbicazione from ARMGUbicazione where Cd_AR = @Cd_AR) begin
		insert into @out(Ordinamento, Cd_MGUbicazione, ScortaDisp, PesoDisp, VolumeDisp)
		select
			Ordinamento			= ROW_NUMBER() over (order by xMOMGCorsia.CPSequenza, ARMGUbicazione.Cd_MGUbicazione)
			, Cd_MGUbicazione	= ARMGUbicazione.Cd_MGUbicazione
			, ScortaDisp		= ARMGUbicazione.xMOScortaMassima
			, PesoDisp			= MGUbicazione.xMOPesoMaxMks
			, VolumeDisp		= MGUbicazione.xMOVolumeMaxMks
		from
			ARMGUbicazione
				inner join MGUbicazione on ARMGUbicazione.Cd_MG = MGUbicazione.Cd_MG And ARMGUbicazione.Cd_MGUbicazione = MGUbicazione.Cd_MGUbicazione
				left join xMOMGCorsia	on MGUbicazione.xCd_xMOMGCorsia = xMOMGCorsia.Cd_xMOMGCorsia And MGUbicazione.Cd_MG = xMOMGCorsia.Cd_MG
		where
				ARMGUbicazione.Cd_MG = @Cd_MG
			And ARMGUbicazione.Cd_AR = @Cd_AR
			And MGUbicazione.xMOTipo = 'S'
	end else begin -- Altrimenti cerco fra tutte le ubicazioni del magazzino specificato
		insert into @out(Ordinamento, Cd_MGUbicazione, ScortaDisp, PesoDisp, VolumeDisp)
		select
			Ordinamento			= ROW_NUMBER() over (order by xMOMGCorsia.CPSequenza, MGUbicazione.Cd_MGUbicazione)
			, Cd_MGUbicazione	= MGUbicazione.Cd_MGUbicazione
			, ScortaDisp		= 0
			, PesoDisp			= MGUbicazione.xMOPesoMaxMks
			, VolumeDisp		= MGUbicazione.xMOVolumeMaxMks
		from
			MGUbicazione
				left join xMOMGCorsia	on MGUbicazione.xCd_xMOMGCorsia = xMOMGCorsia.Cd_xMOMGCorsia And MGUbicazione.Cd_MG = xMOMGCorsia.Cd_MG
		where
				MGUbicazione.Cd_MG = @Cd_MG
			And MGUbicazione.xMOTipo = 'S'
	end

	-- Elimino le ubicazioni escluse dall'operatore
	delete from @out
	where Cd_MGUbicazione in (
		select
			t.x.value('@cd_mgubicazione', 'varchar(20)')
		from @Esclusioni.nodes('/rows/row') t(x)
	)

	declare @Cd_MGEsercizio		char(4) = dbo.afn_MGEsercizio(getdate())

	-- Ricalcolo Quantità, Peso e Volume accoglibile per ogni ubicazione in base a quanto già stoccato in esse
	update @out set
		ScortaDisp		= o.ScortaDisp	- giac.Quantita		-- Sottraggo alla quantità accoglibile quella già presente nell'ubicazione
		, PesoDisp		= o.PesoDisp	- giac.Peso			-- Sottraggo al peso accoglibile quello già presente nell'ubicazione
		, VolumeDisp	= o.VolumeDisp	- giac.Volume		-- Sottraggo al volume accoglibile quello già presente nell'ubicazione
		, Giacenza		= isnull(giac.Quantita, 0)			-- Aumento la giacenza dell'ubicazione così da sapere se già occupata
	from @out o
		inner join (
			-- Sommatoria di Giacenza, Peso e Volume per ogni ubicazione.
			-- Per peso e volume devo moltiplicare la quantità stoccata per il peso/volume unitario di ogni articolo in quanto potrebbero essere differenti
			select
				Cd_MGUbicazione
				, Quantita	= sum(giac.Quantita)
				, Peso		= sum(giac.Quantita * AR.PesoLordoMks)
				, Volume	= sum(giac.Quantita * AR.VolumeMks)
			from
				MGGiacEx(@Cd_MGEsercizio) giac
					inner join AR on giac.Cd_AR	= AR.Cd_AR
			where
				Cd_MG = @Cd_MG
			group by
				Cd_MGUbicazione
			) giac on o.Cd_MGUbicazione = giac.Cd_MGUbicazione

	-- Sottraggo la giacenza nelle ubicazioni già assegnata ad altri operatori
	update @out set
		ScortaDisp		= o.ScortaDisp - giac.Quantita		-- Sottraggo alla quantità accoglibile quella già prenotata da altri operatori
		, PesoDisp		= o.PesoDisp - giac.Peso			-- Sottraggo al peso accoglibile quello già prenotata da altri operatori
		, VolumeDisp	= o.VolumeDisp - giac.Volume		-- Sottraggo al volume accoglibile quello già prenotata da altri operatori
		, Giacenza		= o.Giacenza + giac.Quantita		-- Aumento la giacenza dell'ubicazione così da sapere se già occupata
	from @out o
		inner join (
			-- Recupero tutte le righe temporanee di tutti gli utenti e la sommatoria a parità di ubicazione di quantità, peso e volume
			-- Questo mi consente di tenere in considerazione anche le "prenotazioni" degli altri operatori che stanno stoccando merce
			select
				Cd_MGUbicazione		= t.Cd_MGUbicazione_A
				, Quantita			= sum(t.QtaUMP)
				, Peso				= sum(t.QtaUMP * AR.PesoLordoMks)
				, Volume			= sum(t.QtaUMP * AR.VolumeMks)
			from
				xMOTRRig_T t
					inner join xMOTR		on t.Id_xMOTR		= xMOTR.Id_xMOTR
					inner join xMOTRRig_P p	on t.Id_xMOTRRig_P	= p.Id_xMOTRRig_P
					inner join AR			on p.Cd_AR			= AR.Cd_AR
			where
					t.Cd_MGUbicazione_A is not null
				And xMOTR.Stato = 0
				And t.Cd_MG_A = @Cd_MG
			group by
				t.Cd_MGUbicazione_A
		) giac	on o.Cd_MGUbicazione = giac.Cd_MGUbicazione
	
	-- SCORTA MASSIMA - Cerco un'ubicazione in cui stoccare l'articolo per scorta massima
	select top 1
		@Cd_MGUbicazione = Cd_MGUbicazione
		-- Calcolo la quantità assegnabile
		, @QtaAssgnabile = case when @Quantita > ScortaDisp then ScortaDisp else @Quantita end
	from @out
	where
		-- tutte le ubicazioni che hanno quantità assegnable
		ScortaDisp > 0
	order by Ordinamento

	-- PESO MASSIMO - Cerco un'ubicazione in cui stoccare l'articolo per scorta massima
	-- Se non ho trovato nessuna ubicazione per scorta
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = Cd_MGUbicazione
			, @QtaAssgnabile = case when (@Quantita * AR.PesoLordoMks) > PesoDisp then cast(PesoDisp / AR.PesoLordoMks as int) else (@Quantita * AR.PesoLordoMks) end
		from @out o, (select PesoLordoMks from AR where Cd_AR = @Cd_AR) AR
		where
			PesoDisp > 0 
		order by Ordinamento
	end

	-- VOLUME MASSIMO - Cerco un'ubicazione in cui stoccare l'articolo per volume massimo
	-- Se non ho trovato nessuna ubicazione per peso
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = Cd_MGUbicazione
			, @QtaAssgnabile = case when (@Quantita * AR.VolumeMks) > VolumeDisp then cast(VolumeDisp / AR.VolumeMks as int) else (@Quantita * AR.VolumeMks) end
		from @out o, (select VolumeMks from AR where Cd_AR = @Cd_AR) AR
		where
			VolumeDisp > 0
		order by Ordinamento
	end

	-- PRIMA LIBERA - Propongo la prima ubicazione vuota
	-- Se non ho trovato nessuna ubicazione per volume
	if isnull(@Cd_MGUbicazione, '') = '' And isnull(@QtaAssgnabile, 0) = 0 begin
		select top 1
			@Cd_MGUbicazione = o.Cd_MGUbicazione
			, @QtaAssgnabile = @Quantita
		from @out o
		where
			o.Giacenza = 0
		order by o.Ordinamento
	end

	-- Se la quantità assegnabile è nulla la imposta a zero
	set @QtaAssgnabile = ISNULL(@QtaAssgnabile, 0)

	set @Esclusioni = isnull(@Esclusioni, '<rows />')

	return 1

end
go

-- ---------------------------------------------------------------------------------------------------
-- #4		esegue il garant deli oggetti ............................................................
-- ---------------------------------------------------------------------------------------------------

declare @sqlgarant nvarchar(max)
declare @Type char(2)
declare @xObj cursor 
declare @Last_Type char(2)
declare @Ret Int

set @xObj = cursor for 
	--Crea lo script per il grant come EXECUTE per stored procedure (p) e funzioni scalari (fn) e SELECT per gli altri oggetti 
	select 
		'grant ' + case when type in ('p', 'fn') then 'execute' else 'select' end + ' on [' + name + '] to public', Type
	from 
		sys.all_objects 
	where 
		name like 'x%' and
		is_ms_shipped = 0 and
		lower(type) in ('u', 'tf', 'if', 'v', 'p', 'fn')
	order by 
		type

open @xObj
fetch next from @xObj into @sqlgarant, @Type

while (@@fetch_status = 0)
begin
	--if ISNULL(@Last_Type, '') <> @Type begin
	--	set @Last_Type = @Type
	--	print ' -- ' + 
	--	case @Type
	--		when 'AF' then 'funzione di aggregazione (CLR)'
	--		when 'C' then 'vincolo CHECK'
	--		when 'D' then 'DEFAULT (vincolo o valore autonomo)'
	--		when 'F' then 'vincolo FOREIGN KEY'
	--		when 'FN' then 'funzione scalare SQL'
	--		when 'FS' then 'funzione scalare di assembly (CLR)'
	--		when 'FT' then 'funzione valutata a livello di tabella assembly (CLR)'
	--		when 'IF' then 'funzione SQL inline valutata a livello di tabella'
	--		when 'IT' then 'tabella interna'
	--		when 'P' then 'stored procedure SQL'
	--		when 'PC' then 'stored procedure di assembly (CLR)'
	--		when 'PG' then 'guida di piano'
	--		when 'PK' then 'vincolo PRIMARY KEY'
	--		when 'R' then 'regola (tipo obsoleto, autonoma)'
	--		when 'RF' then 'procedura-filtro-replica'
	--		when 'S' then 'tabella di base di sistema'
	--		when 'SN' then 'sinonimo'
	--		when 'SQ' then 'coda di servizio'
	--		when 'TA' then 'trigger DML assembly (CLR)'
	--		when 'TF' then 'funzione valutata a livello di tabella SQL'
	--		when 'TR' then 'trigger DML SQL'
	--		when 'TT' then 'tipo tabella'
	--		when 'U' then 'tabella (definita dall''utente)'
	--		when 'UQ' then 'vincolo UNIQUE'
	--		when 'V' then 'vista'
	--		when 'X' then 'stored procedure estesa'
	--	else
	--		''
	--	end
	--end
	--print @sqlgarant
	
	if isnull(@sqlgarant, '') <> '' begin
		EXECUTE  @RET = sp_executesql @sqlgarant
	end
	fetch next from @xObj into @sqlgarant, @Type
end
close @xObj
deallocate @xObj


-- -------------------------------------------------------------
-- #5		aggiorna le viste standard di Arca Evo 
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- #6		aggiorna tutte le viste 
-- -------------------------------------------------------------
exec('asp_du_refreshviews 1')
go

-- DEPRECATO !!!
--exec('asp_du_refreshviews 0')
--go

-- -------------------------------------------------------------
-- #7		mostra della versione finale
-- -------------------------------------------------------------
declare @CurrVer varchar(9)
set @CurrVer = (select top 1 DBFullver from xMOVersion order by 1 desc)
print 'Database versione finale ' + @CurrVer

set nocount off
go

