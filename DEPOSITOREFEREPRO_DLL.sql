DELIMITER ;
DROP PROCEDURE IF EXISTS DEPOSITOREFEREPRO;


DELIMITER $$
CREATE PROCEDURE `DEPOSITOREFEREPRO`(
	Par_InstitucionID       INT(11),			-- ID Institucion
	Par_NumCtaInstit        VARCHAR(20),		-- Numero de Cuenta de la Institucion
	Par_FechaOperacion      DATE,				-- Fecha de Operacion
	Par_ReferenciaMov       VARCHAR(150),		-- Referencia Movimiento
	Par_DescripcionMov      VARCHAR(150),		-- Descripcion Movimiento

	Par_NatMovimiento       CHAR(1),			-- Naturaleza de Movimiento
	Par_MontoMov            DECIMAL(12,2),		-- Monto Movimiento
	Par_MontoPendApli       DECIMAL(12,2),		-- Monto Pendiente por Aplicar
	Par_TipoCanal           INT(11),			-- Tipo de Canal
	Par_TipoDeposito        CHAR(1),			-- Tipo de Deposito

	Par_Moneda              INT(11),			-- ID Moneda
	Par_InsertaTabla        CHAR(1),			-- Indica si se inserta en la Tabla
	Par_Folio               INT(11),			-- Numero de Folio de Operacion

	Par_Salida              CHAR(1),			-- Parametro de salida
	OUT Par_NumErr          INT(11),            -- Numero de Error
	OUT Par_ErrMen          VARCHAR(400),       -- Descripcion Error
	OUT Par_Consecutivo     VARCHAR(50), 		-- Valor del Consecutivo

	Aud_EmpresaID           INT(11),			-- Parametro de Auditoria
	Aud_Usuario             INT(11),    		-- Parametro de Auditoria
	Aud_FechaActual         DATETIME,			-- Parametro de Auditoria
	Aud_DireccionIP         VARCHAR(15),		-- Parametro de Auditoria
	Aud_ProgramaID          VARCHAR(50),		-- Parametro de Auditoria
	Aud_Sucursal            INT(11),			-- Parametro de Auditoria
	Aud_NumTransaccion      BIGINT(20)			-- Parametro de Auditoria
)
TerminaStore: BEGIN

    -- V_1.1.3

	-- Declaracion de Constantes
	DECLARE Entero_Cero         INT;
	DECLARE Cadena_Vacia        CHAR(1);
	DECLARE Decimal_Cero        DECIMAL(12,2);
	DECLARE Nat_Abono           CHAR(1);
	DECLARE Nat_Cargo           CHAR(1);
	DECLARE Act_Saldo           INT(2); -- tipo de actualizacion de saldo CUENTASAHOTESOACT
	DECLARE NumCredito          INT; -- Corresponde con la tabla TIPOCANAL
	DECLARE CuentaAhorro        INT; -- Corresponde con la tabla TIPOCANAL
	DECLARE NumCliente          INT; -- Corresponde con la tabla TIPOCANAL
	DECLARE Aplicado            CHAR(1);
	DECLARE DepRefeEfec         INT;
	DECLARE Salida_SI           CHAR(1);
	DECLARE Salida_NO           CHAR(1);
	DECLARE TipoMovDepRef       CHAR(4); -- corresponde con la tabla TIPOSMOVTESO
	DECLARE Var_FechaSistema    DATE;
	DECLARE Con_AhoCapital      INT;
	DECLARE Var_NO              CHAR(1);
	DECLARE Con_DescripTipoMov  CHAR(100);
	DECLARE Var_IVA             DECIMAL(12,2);
	DECLARE Var_NumErr          INT;
	DECLARE Var_ErrMen          VARCHAR(400);
	DECLARE	TipoDepositoNI		TINYINT UNSIGNED;
    DECLARE IdentificadoNO	    CHAR(2);
    DECLARE Entero_Uno			INT(11);
	DECLARE Var_CtaPrepago		VARCHAR(50);	-- Cuenta contable para movimiento de ahorro que no son de Captacion
	DECLARE Var_EstActiva		CHAR(1);		-- Estatus Activa de la Cuenta de Ahorro

	DECLARE	DESC_MOV			VARCHAR(100);  
	DECLARE	DESC_MOV_IVA		VARCHAR(100);  
	DECLARE MOV_CONTA			INT;
	DECLARE MOV_CONTA_IVA		INT;
	DECLARE	CONCEPTO_CONTA		INT;
	DECLARE ALTA_POLIZA_NO			CHAR(1);
	DECLARE INSTITUCION_CASHIN  INT(11);
	DECLARE CUENTA_CASHIN  		VARCHAR(20);
	DECLARE ESTATUS_PENDIENTE	CHAR(1);
	DECLARE CONS_SI				CHAR(1);
	DECLARE DESC_COBRO_PEND		VARCHAR(300);


	-- Declaracion de Variables

	DECLARE Var_Cargos          DECIMAL(12,4);
	DECLARE Var_Abonos          DECIMAL(12,4);
	DECLARE Var_FolioOperacion  INT;
	DECLARE Var_Vacio           CHAR(1);
	DECLARE Var_Status          CHAR(2);
	DECLARE Var_DepEfec         CHAR(1);
	DECLARE Var_OtroDep         CHAR(1);
	DECLARE Var_Efectivo        CHAR(1);
	DECLARE Par_TipoPago        CHAR(1);
	DECLARE Var_SiInserta       CHAR(1);
	DECLARE Var_esPrincipal     CHAR(1);
	DECLARE Var_Consecutivo     BIGINT(20);
	DECLARE Var_NatMovimiento   CHAR(1);
	DECLARE Var_Transaccion     BIGINT;
	DECLARE	DesDepositoIdent	VARCHAR(100);

	DECLARE CliCredito          INT;
	DECLARE CliClienteID        INT(11);
	DECLARE CliCuentaID         INT;
	DECLARE CliMonedaID         INT;
	DECLARE NatMovimiento       CHAR(1);
	DECLARE DepRefeDoc          INT;
	DECLARE CliCuentaAhoID      INT;
	DECLARE Par_TipoMovAhoID    INT;
	DECLARE ClienCuentaAhoID    INT;
	DECLARE Var_Cuenta          VARCHAR(20);
	DECLARE Var_CuentaBancaria  VARCHAR(20);
	DECLARE Fecha_Valida        DATE;
	DECLARE DiaHabil            CHAR(1);
	DECLARE DescripcionCredito  VARCHAR(50);
	DECLARE DescripcionCuenta   VARCHAR(50);
	DECLARE DescripcionCliente  VARCHAR(50);
	DECLARE EmitePoliza         CHAR(1);
	DECLARE	CuentaKuboGlobal	VARCHAR(12);
	DECLARE Procedimiento		VARCHAR(20);
	DECLARE	TipoConcentra		TINYINT UNSIGNED;

	DECLARE Var_ConceptoCon     INT;
	DECLARE Var_ConceptoConDep  INT;
	DECLARE Var_NatConta        CHAR(1);
	DECLARE Var_AltaMovAho      CHAR(1);
	DECLARE Var_TipoMovAho      VARCHAR(4);
	DECLARE Var_NatAhorro       CHAR(1);
	DECLARE MsgError            VARCHAR(50);
	DECLARE Var_PrimerDiaMes    DATE;
	DECLARE Var_Poliza          BIGINT(20);
	DECLARE NoEmitePoliza       CHAR(1);
	DECLARE Var_MovComDepRef    CHAR(4);
	DECLARE Var_CuentaAhoID     INT(12);
	DECLARE Var_Comision        DECIMAL(12,2);
	DECLARE	Var_CuentaConcen	INT(12);
	DECLARE	Var_ClienteConcen	INT(12);
	DECLARE	Var_MonedaConcen	INT;

	DECLARE Var_CuentaAhoIDTMP  VARCHAR(20);
	DECLARE Var_InstitucionID   INT(11);
	DECLARE Var_FechaAplica    	DATE;
	DECLARE Var_MontoMov       	DECIMAL(12,2);
	DECLARE Var_DescripcionMov  VARCHAR(100);
	DECLARE Var_ReferenciaMov   VARCHAR(100);
	DECLARE Var_RefereCtaCon   	VARCHAR(100);
	DECLARE Var_RefereCtaCli   	VARCHAR(100);
	DECLARE Var_TipoDeposito    CHAR(1);
	DECLARE Var_TipoCanal      	INT(11);
	DECLARE Var_MonedaId        INT(11);
	DECLARE Var_NumTransaccion  BIGINT(20);
	DECLARE Var_Consecutivo2  	BIGINT(20);
	DECLARE	Var_DescripCtaMov	VARCHAR(50);
	DECLARE	Var_InstitucionBanc	VARCHAR(20);
	DECLARE Var_Transferencia   CHAR(1);
	DECLARE Var_EsCaptacion		CHAR(1);	-- Indica si una cuenta de ahorro es de tipo captacion o no
	DECLARE Var_CtaContConcent	VARCHAR(50);	-- Cuenta para insercion directa a DETALLEPOLIZA
	
	DECLARE Var_CantPenAct		DECIMAL(12,2);
	DECLARE Var_MontoCob		DECIMAL(12,2);
	DECLARE Var_MontoCobIva		DECIMAL(12,2);
	DECLARE Var_CantPenCom		DECIMAL(12,2);
	DECLARE Var_TipoMovCashIn	CHAR(4);
	DECLARE Var_TipoMovIva		CHAR(4);
	DECLARE Var_SaldoDispon		DECIMAL(12,2);
	DECLARE Var_PagaIVA			CHAR(1);
	DECLARE Var_FechaActCob		DATETIME;

	-- Asignacion de Constantes
	SET Entero_Cero         := 0;		-- Entero Cero
	SET Decimal_Cero        := 0.0;		-- DECIMAL Cero
	SET Aplicado            := 'A';		-- Aplicado
	SET Cadena_Vacia        := '';		-- Cadena Vacia
	SET Nat_Abono           := 'A';		-- Naturaleza de Movimiento: Abono
	SET Nat_Cargo           := 'C';		-- Naturaleza de Movimiento: Cargo
	SET Act_Saldo           := 1; 		-- Tipo de actualizacion de saldo CUENTASAHOTESOACT
	SET NumCredito          := 1;		-- Corresponde con la tabla TIPOCANAL
	SET CuentaAhorro        := 2; 		-- Corresponde con la tabla TIPOCANAL
	SET NumCliente          := 3; 		-- Corresponde con la tabla TIPOCANAL
	SET DepRefeEfec         := 14;		-- Deposito Referenciado Efectivo
	SET Var_MovComDepRef    := 228;		-- Comision Deposito Referenciado
	SET Salida_SI           := 'S'; 	-- Salida: SI
	SET Salida_NO           := 'N'; 	-- Salida: NO
	SET TipoMovDepRef       := '1'; 	-- Corresponde con la tabla TIPOSMOVTESO (deposito Referenciado)
	SET Con_AhoCapital      := 1; 		-- Ahorro Capital
	SET Var_NO              := 'N';		-- Valor: NO
	SET Var_IVA             := 0.00;	-- Valor IVA
	SET	TipoDepositoNI		:= 1;		-- Tipo de Deposito no Identificado
	SET	CuentaKuboGlobal	:= '210201010101';			-- Cuenta Kubo Global
	SET	Procedimiento		:= 'DEPOSITOREFEREPRO';		-- Descripcion Procedimiento
	SET IdentificadoNO		:= 'NI';	-- No Identificado
    SET Entero_Uno			:= 1;		-- Entero Uno
	SET Var_CtaPrepago		:= '310201010101';	-- Cuenta contable para movimiento de ahorro que no son de Captacion

	SET DESC_MOV 			:= 'Comisión deposito Referenciado';
	SET DESC_MOV_IVA 		:= 'IVA comisión deposito Referenciado';
	SET Var_TipoMovCashIn 		:= 228;
	SET Var_TipoMovIva		:= 229;
	SET CONCEPTO_CONTA		:= 200;
	SET MOV_CONTA 			:= 30;
	SET MOV_CONTA_IVA		:= 31;
	SET ALTA_POLIZA_NO		:= 'N';
	SET INSTITUCION_CASHIN	:= 24;
	SET CUENTA_CASHIN		:= '1145342518';
	SET ESTATUS_PENDIENTE	:= 'P';
	SET CONS_SI				:= 'S';
	SET DESC_COBRO_PEND 	:= 'COBROS PENDIENTES ';

	-- Asignacion de Variables
	SET Var_Vacio           := '';		-- Valor Vacio
	SET Var_Status          := 'NI';	-- Valor Estatus: NI
	SET Var_DepEfec         := 'S';		-- Valor Deposito Efectivo: SI
	SET Var_OtroDep         := 'N';		-- Valor Otro Deposito
	SET Var_Efectivo        := 'E';		-- Valor Efectivo
	SET Var_SiInserta       := 'S';		-- Valor Inserta Tabla : SI
	SET Var_esPrincipal     := 'S';		-- Valor es Principal

	SET CliCredito          := 0;		-- Valor Credito
	SET CliClienteID        := 0;		-- Valor Cliente
	SET CliCuentaID         := 0;		-- Valor Cuenta
	SET CliMonedaID         := 0;		-- Valor Moneda
	SET NatMovimiento       := 'A';     -- Naturaleza de Movimiento: Abono
	SET DepRefeDoc          := 16; 		-- Deposito Referenciado Documento
	SET DescripcionCredito  := 'DEPOSITO A CREDITO';		-- Descripcion Deposito a Credito
	SET DescripcionCuenta   := 'DEPOSITO A CUENTA';			-- Descripcion Deposito a Cuenta
	SET DescripcionCliente  := 'DEPOSITO A CLIENTE';		-- Descripcion Deposito a Cliente
	SET EmitePoliza         := 'S';		-- Emite Poliza: SI
	SET NoEmitePoliza       := 'N';		-- Emite Poliza: NO
	SET Var_ConceptoCon     := 54;		-- Concepto Contable: Pago de Credito
	SET Var_NatConta        := 'C';		-- Naturaleza Cargo
	SET Var_AltaMovAho      := 'S';		-- Alta Movimiento de Ahorro: SI
	SET Var_TipoMovAho      := '101';	-- Tipo de Movimiento: Pago de Credito
	SET Var_NatAhorro       := 'A';		-- Naturaleza Ahorro
	SET MsgError            := 'MsgError';		-- Mensaje de Error
	SET Con_DescripTipoMov  :=  'COMISION POR DEPOSITO REFERENCIADO';	-- Descripcion Comision por Deposito Referenciado
	SET Var_Comision        := 0.00;	-- Valor Comision
	SET	DesDepositoIdent	:= 'DEPOSITO ';		-- Descripcion Deposito
	SET	TipoConcentra		:= 5;		-- Tipo Concentradora
	SET Par_Consecutivo     := 'NO';	-- Valor Consecutivo
	SET Var_Transferencia   := 'T';		-- Valor Transferencia
	SET Var_EstActiva		:= 'A';		-- Estatus Activa de la Cuenta de Ahorro

  	ManejoErrores: BEGIN
	  	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		  	BEGIN
				SET Par_NumErr := 999;
				SET Par_ErrMen := CONCAT('El SAFI ha tenido un problema al concretar la operacion. ',
							  'Disculpe las molestias que esto le ocasiona. Ref: SP-DEPOSITOREFEREPRO.');
			END;
			
			SET Var_FechaSistema :=( SELECT FechaSistema FROM PARAMETROSSIS  );
			SET Var_FolioOperacion := (SELECT IFNULL(MAX(FolioCargaID),Entero_Cero)+1 FROM DEPOSITOREFERE);

			-- para obtener primer dia del mes
			SET Var_PrimerDiaMes    := CONVERT(DATE_ADD(Var_FechaSistema, INTERVAL -1*(DAY(Var_FechaSistema))+1 DAY),DATE);


			SET	Var_InstitucionBanc	:= (SELECT 	InstitucionID
										FROM 	TMPDEPOSITOS
										WHERE 	FolioCargaID = Par_Folio
										AND 	NumTransaccion = Aud_NumTransaccion);

			SET Var_InstitucionBanc := IFNULL(Var_InstitucionBanc, Cadena_Vacia);

			SELECT  CuentaAhoID,		InstitucionID,		FechaAplica,		MontoMov,		DescripcionMov,
					ReferenciaMov,		TipoDeposito,		TipoCanal,			MonedaId,		NumTransaccion
			INTO    Var_CuentaAhoIDTMP,	Var_InstitucionID,	Var_FechaAplica,	Var_MontoMov,	Var_DescripcionMov,
					Var_ReferenciaMov,	Var_TipoDeposito,	Var_TipoCanal,		Var_MonedaId,	Var_NumTransaccion
			FROM 	TMPDEPOSITOS
			WHERE 	FolioCargaID	= 	Par_Folio
			AND 	NumTransaccion	= 	Aud_NumTransaccion;

            SET Fecha_Valida := (SELECT DIASHABILANTERCAL(Var_FechaAplica,Entero_Cero));

			SELECT  NumCtaInstit INTO Var_CuentaBancaria
				FROM CUENTASAHOTESO
				WHERE NumCtaInstit = Var_CuentaAhoIDTMP;

			IF(IFNULL(Var_CuentaBancaria,Cadena_Vacia) = Cadena_Vacia)THEN
					SET Par_NumErr := 1;
					SET Par_ErrMen := 'No Existe el Numero de Cuenta.';
					SET Par_Consecutivo := 'NO';
				   LEAVE ManejoErrores;
			END IF;


			IF( NOT EXISTS(SELECT TipoCanalID
					FROM TIPOCANAL
					WHERE TipoCanalID = Var_TipoCanal)) THEN
						SET Par_NumErr := 7;
						SET Par_ErrMen := 'No existe el Tipo de Canal.';
						SET Par_Consecutivo := 'NO';
						LEAVE ManejoErrores;
			END IF;


			IF(Fecha_Valida > Var_FechaSistema) THEN
					SET Par_NumErr := 9;
					SET Par_ErrMen := 'La Fecha de Operacion no debe ser mayor a la del sistema.';
					SET Par_Consecutivo := 'NO';
					LEAVE ManejoErrores;
			END IF;
/*
			CALL DIASFESTIVOSCAL(
				Var_FechaAplica,        Entero_Cero,        Fecha_Valida,       DiaHabil,           Aud_EmpresaID,
				Aud_Usuario,            Aud_FechaActual,    Aud_DireccionIP,    Aud_ProgramaID,     Aud_Sucursal,
				Aud_NumTransaccion);
*/
			IF(EXISTS(SELECT TipoCanalID
				FROM TIPOCANAL
				WHERE TipoCanalID = Var_TipoCanal)) THEN

			IF(Var_TipoDeposito = Var_Efectivo)THEN
				SET Par_TipoMovAhoID := DepRefeEfec;
				SET Par_TipoPago := Var_Efectivo;
				SET Var_ConceptoConDep := 14;
				SET Var_TipoMovAho := 14;
			ELSE
				SET Par_TipoMovAhoID := DepRefeDoc;
				SET Par_TipoPago := Var_Transferencia;
				SET Var_ConceptoConDep := 16;
			END IF;


			IF(NumCredito = Var_TipoCanal)THEN
				SELECT CreditoID, ClienteID, CuentaID, MonedaID
				INTO CliCredito, CliClienteID, CliCuentaID, CliMonedaID
				FROM CREDITOS
				WHERE CreditoID = Var_ReferenciaMov
				AND MonedaID = Var_MonedaId;
				
				SET Var_CuentaAhoID := CliCuentaID;

				IF(IFNULL(CliCredito, Entero_Cero) <> Entero_Cero ) THEN
					IF(Par_InsertaTabla = Var_SiInserta) THEN
						-- IF INSERTA TABLE ES IGUAL A S ENTONCES INSERTA LO DEMAS
						CALL FOLIOSAPLICAACT('DEPOSITOPAGOCRE', Var_Consecutivo);

						CALL DEPOSITOPAGOCREALT(
							Fecha_Valida,    	Var_NumTransaccion, Var_Consecutivo,    CliCredito,     CliClienteID,
							Par_TipoPago,       Var_MontoMov,       Aud_EmpresaID,      Aud_Usuario,    Aud_FechaActual,
							Aud_DireccionIP,    Aud_ProgramaID,     Aud_Sucursal,       Var_NumTransaccion);

						IF(Fecha_Valida < Var_PrimerDiaMes) THEN /* si la fecha de operacion es del mes anterior se insertan movimientos de ahorro en el historico*/
							IF(Var_NatAhorro = Nat_Cargo) THEN
								SET Var_Cargos  := Var_MontoMov;
								SET Var_Abonos  := Decimal_Cero;
							ELSE
								SET Var_Cargos  := Decimal_Cero;
								SET Var_Abonos  := Var_MontoMov;
							END IF;

							CALL CUENTASAHOMOVHIALT(/* inserta movimientos en la tabla del historico .- `HIS-CUENAHOMOV`*/
								CliCuentaID,        Aud_NumTransaccion,	Fecha_Valida,	Var_NatAhorro,	Var_MontoMov,
								DescripcionCredito, Var_ReferenciaMov,	Var_TipoMovAho,	Aud_EmpresaID,	Aud_Usuario,
								Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion);


							CALL MAESTROPOLIZASALT(
								Var_Poliza,         Aud_EmpresaID,		Fecha_Valida,	Var_NatAhorro,	Var_ConceptoCon,
								DescripcionCredito, Salida_NO,			Par_NumErr,		Par_ErrMen,		Aud_Usuario,
                                Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion);

                            IF(Par_NumErr <> Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL POLIZASAHORROPRO(
								Var_Poliza,         Aud_EmpresaID,          Fecha_Valida,		CliClienteID,       FNCONCEPTOAHOPREPAGO(CliCuentaID, Con_AhoCapital),
								CliCuentaID,        Var_MonedaId,           Var_Cargos,         Var_Abonos,         DescripcionCredito,
								Var_ReferenciaMov,  Salida_NO,				Par_NumErr,         Par_ErrMen,         Aud_Usuario,
                                Aud_FechaActual,	Aud_DireccionIP,    	Aud_ProgramaID,		Aud_Sucursal,       Var_NumTransaccion);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL CONTATESORERIAPRO(
								Entero_Cero,            Var_MonedaId,       Var_InstitucionID,      Var_CuentaBancaria,	Entero_Cero,
								Entero_Cero,            Entero_Cero,        Fecha_Valida,			Fecha_Valida,		Var_MontoMov,
								DescripcionCredito,     Var_ReferenciaMov,  CliCredito,             NoEmitePoliza,		Var_Poliza,
								Var_ConceptoCon,        Entero_Cero,        Var_NatConta,           Var_NO,				CliCuentaID,
								CliClienteID,           Var_TipoMovAho,     Var_NatAhorro,          Par_NumErr,			Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,            Aud_FechaActual,	Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

						ELSE
							CALL CONTATESORERIAPRO(
								Entero_Cero,            Var_MonedaId,       Var_InstitucionID,	Var_CuentaBancaria,		Entero_Cero,
								Entero_Cero,            Entero_Cero,        Fecha_Valida,		Fecha_Valida,			Var_MontoMov,
								DescripcionCredito,     Var_ReferenciaMov,  CliCredito,			EmitePoliza,			Var_Poliza,
								Var_ConceptoCon,        Entero_Cero,        Var_NatConta,		Var_AltaMovAho,			CliCuentaID,
								CliClienteID,           Var_TipoMovAho,     Var_NatAhorro,		Par_NumErr,				Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,		Aud_FechaActual,		Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;
						END IF;

						CALL CUENTASAHOBLOQNIVPRO(	CliCuentaID, 		Aud_Usuario, 		Fecha_Valida, 		Salida_NO, 			Par_NumErr,
													Par_ErrMen, 		Aud_EmpresaID, 		Aud_Usuario,		Aud_FechaActual,	Aud_DireccionIP,
													Aud_ProgramaID,		Aud_Sucursal,		Aud_NumTransaccion);

						IF( Par_NumErr <> Entero_Cero ) THEN
							LEAVE ManejoErrores;
						END IF;

						SET Var_Status  := Aplicado;
					END IF;
				ELSE
					IF Par_InsertaTabla = Var_NO THEN
						SET Par_NumErr      := '040';
						SET Par_ErrMen      := CONCAT("El Credito no Existe: ", CONVERT(Var_ReferenciaMov, CHAR));
						SET Par_Consecutivo := 'NI';
						LEAVE ManejoErrores;
					END IF;
				END IF;

			END IF;

			IF(CuentaAhorro = Var_TipoCanal)THEN
				SELECT CuentaAhoID, ClienteID, MonedaID
					INTO CliCuentaAhoID, CliClienteID, CliMonedaID
					FROM CUENTASAHO
					WHERE CuentaAhoID = Var_ReferenciaMov
					AND MonedaID = Var_MonedaId;
					SET Var_CuentaAhoID := CliCuentaAhoID;

				IF(IFNULL(CliCuentaAhoID, Entero_Cero) <> Entero_Cero) THEN
					IF(Par_InsertaTabla = Var_SiInserta) THEN
						IF(Fecha_Valida < Var_PrimerDiaMes) THEN /* si la fecha de operacion es del mes anterior se insertan movimientos de ahorro en el historico*/
							IF(Var_NatAhorro = Nat_Cargo) THEN
								SET Var_Cargos  := Var_MontoMov;
								SET Var_Abonos  := Decimal_Cero;
							ELSE
								SET Var_Cargos  := Decimal_Cero;
								SET Var_Abonos  := Var_MontoMov;
							END IF;

							CALL CUENTASAHOMOVHIALT(/* inserta movimientos en la tabla del historico .- `HIS-CUENAHOMOV`*/
								CliCuentaAhoID,     Var_NumTransaccion,	Fecha_Valida,	Var_NatAhorro,	Var_MontoMov,
								DescripcionCuenta,  Var_ReferenciaMov,	Var_TipoMovAho,	Aud_EmpresaID,	Aud_Usuario,
								Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

							CALL MAESTROPOLIZASALT(
								Var_Poliza,         Aud_EmpresaID,		Fecha_Valida,	Var_NatAhorro,	Var_ConceptoCon,
								DescripcionCuenta,  Salida_NO,			Par_NumErr,		Par_ErrMen,		Aud_Usuario,
                                Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

                            IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL POLIZASAHORROPRO(
								Var_Poliza,         Aud_EmpresaID,		Fecha_Valida,	CliClienteID,	FNCONCEPTOAHOPREPAGO(CliCuentaAhoID, Con_AhoCapital),
								CliCuentaAhoID,     Var_MonedaId,		Var_Cargos,		Var_Abonos,		DescripcionCuenta,
								Var_ReferenciaMov,  Salida_NO,			Par_NumErr,		Par_ErrMen,		Aud_Usuario,
                                Aud_FechaActual,	Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL CONTATESORERIAPRO(
								Entero_Cero,            Var_MonedaId,       Var_InstitucionID,	Var_CuentaBancaria,     Entero_Cero,
								Entero_Cero,            Entero_Cero,        Fecha_Valida,		Fecha_Valida,			Var_MontoMov,
								DescripcionCuenta,      Var_ReferenciaMov,  CliCuentaAhoID,		NoEmitePoliza,          Var_Poliza,
								Var_ConceptoCon,        Entero_Cero,        Var_NatConta,		Var_NO,                 CliCuentaAhoID,
								CliClienteID,           Var_TipoMovAho,     Var_NatAhorro,		Par_NumErr,             Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,		Aud_FechaActual,        Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

						ELSE

							CALL CONTATESORERIAPRO(
								Entero_Cero,        	Var_MonedaId,           Var_InstitucionID,  	Var_CuentaBancaria, 	Entero_Cero,
								Entero_Cero,            Entero_Cero,            Fecha_Valida,			Fecha_Valida,           Var_MontoMov,
								DescripcionCuenta,      Var_ReferenciaMov,  	CliCuentaAhoID,         EmitePoliza,            Var_Poliza,
								Var_ConceptoConDep,     Entero_Cero,        	Var_NatConta,           Var_AltaMovAho,         CliCuentaAhoID,
								CliClienteID,           Var_TipoMovAho,         Var_NatAhorro,          Par_NumErr,            	Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,          Aud_Usuario,            Aud_FechaActual,      	Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,           Var_NumTransaccion);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;
						END IF;

						CALL CUENTASAHOBLOQNIVPRO(	CliCuentaAhoID,		Aud_Usuario,		Fecha_Valida,		Salida_NO,			Par_NumErr,
													Par_ErrMen,			Aud_EmpresaID,		Aud_Usuario,			Aud_FechaActual,	Aud_DireccionIP,
													Aud_ProgramaID,		Aud_Sucursal,		Aud_NumTransaccion);

						IF( Par_NumErr <> Entero_Cero ) THEN
							LEAVE ManejoErrores;
						END IF;

						SET Var_Status  := Aplicado;
					END IF;
				ELSE
					IF Par_InsertaTabla = Var_NO THEN
							SET Par_NumErr      := '042';
							SET Par_ErrMen      := CONCAT("El Numero de Cuenta no Existe: ", CONVERT(Var_ReferenciaMov, CHAR));
							SET Par_Consecutivo := 'NI';
							SET Par_Consecutivo := 'NI';
							LEAVE ManejoErrores;
					END IF;
				END IF;
			END IF;

			IF(NumCliente = Var_TipoCanal)THEN

				SELECT CuentaAhoID, ClienteID, MonedaID
				INTO ClienCuentaAhoID, CliClienteID, CliMonedaID
					FROM CUENTASAHO
					 WHERE ClienteID = Var_ReferenciaMov
					  AND esPrincipal = Var_esPrincipal
						AND MonedaID = Var_MonedaId
						AND Estatus = Var_EstActiva;

				SET Var_CuentaAhoID := ClienCuentaAhoID;

				IF(IFNULL(ClienCuentaAhoID, Entero_Cero) <> Entero_Cero) THEN
					IF(Par_InsertaTabla = Var_SiInserta) THEN
						IF(Fecha_Valida < Var_PrimerDiaMes) THEN /* si la fecha de operacion es del mes anterior se insertan movimientos de ahorro en el historico*/
							IF(Var_NatAhorro = Nat_Cargo) THEN
								SET Var_Cargos  := Var_MontoMov;
								SET Var_Abonos  := Decimal_Cero;
							ELSE
								SET Var_Cargos  := Decimal_Cero;
								SET Var_Abonos  := Var_MontoMov;
							END IF;

							CALL CUENTASAHOMOVHIALT(/* inserta movimientos en la tabla del historico .- `HIS-CUENAHOMOV`*/
								ClienCuentaAhoID,   Var_NumTransaccion,     Fecha_Valida,	Var_NatAhorro,	Var_MontoMov,
								DescripcionCliente, Var_ReferenciaMov,      Var_TipoMovAho,	Aud_EmpresaID,	Aud_Usuario,
								Aud_FechaActual,    Aud_DireccionIP,        Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

							CALL MAESTROPOLIZASALT(
								Var_Poliza,         Aud_EmpresaID,		Fecha_Valida,	Var_NatAhorro,	Var_ConceptoCon,
								DescripcionCliente, Salida_NO,			Par_NumErr,		Par_ErrMen,		Aud_Usuario,
                                Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL POLIZASAHORROPRO(
								Var_Poliza,         Aud_EmpresaID,		Fecha_Valida,	CliClienteID,	FNCONCEPTOAHOPREPAGO(ClienCuentaAhoID, Con_AhoCapital),
								ClienCuentaAhoID,   Var_MonedaId,		Var_Cargos,		Var_Abonos,		DescripcionCliente,
								Var_ReferenciaMov,  Salida_NO,			Par_NumErr,		Par_ErrMen,		Aud_Usuario,
                                Aud_FechaActual,	Aud_DireccionIP,	Aud_ProgramaID,	Aud_Sucursal,	Var_NumTransaccion
							);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

							CALL CONTATESORERIAPRO(
								Entero_Cero,            Var_MonedaId,       Var_InstitucionID,	Var_CuentaBancaria,	Entero_Cero,
								Entero_Cero,            Entero_Cero,        Fecha_Valida,		Fecha_Valida,		Var_MontoMov,
								DescripcionCliente,     Var_ReferenciaMov,  CliClienteID,		NoEmitePoliza,		Var_Poliza,
								Var_ConceptoCon,        Entero_Cero,        Var_NatConta,		Var_NO,				ClienCuentaAhoID,
								CliClienteID,           Var_TipoMovAho,     Var_NatAhorro,		Par_NumErr,			Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,		Aud_FechaActual,	Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion
							);

							IF(Par_NumErr!=Entero_Cero) THEN
								LEAVE ManejoErrores;
							END IF;

						ELSE
							 CALL CONTATESORERIAPRO(
								Entero_Cero,            Var_MonedaId,           Var_InstitucionID,  Var_CuentaBancaria,     Entero_Cero,
								Entero_Cero,            Entero_Cero,            Fecha_Valida,		Fecha_Valida,           Var_MontoMov,
								DescripcionCliente,     Var_ReferenciaMov,      CliClienteID,       EmitePoliza,            Var_Poliza,
								Var_ConceptoConDep,     Entero_Cero,            Var_NatConta,       Var_AltaMovAho,         ClienCuentaAhoID,
								CliClienteID,           Var_TipoMovAho,         Var_NatAhorro,      Par_NumErr,            	Par_ErrMen,
								Entero_Cero,            Aud_EmpresaID,          Aud_Usuario,        Aud_FechaActual,        Aud_DireccionIP,
								Aud_ProgramaID,         Aud_Sucursal,           Var_NumTransaccion
							);

								IF(Par_NumErr!=Entero_Cero) THEN
									LEAVE ManejoErrores;
								END IF;
						END IF;

						CALL CUENTASAHOBLOQNIVPRO(	ClienCuentaAhoID,	Aud_Usuario,		Fecha_Valida,		Salida_NO,			Par_NumErr,
													Par_ErrMen,			Aud_EmpresaID,		Aud_Usuario,			Aud_FechaActual,	Aud_DireccionIP,
													Aud_ProgramaID,		Aud_Sucursal,		Aud_NumTransaccion);

						IF( Par_NumErr <> Entero_Cero ) THEN
							LEAVE ManejoErrores;
						END IF;

						SET Var_Status  := Aplicado;
					END IF;
				ELSE
					IF Par_InsertaTabla = Var_NO THEN
							SET Par_NumErr      := '043';
							SET Par_ErrMen      := CONCAT("El Cliente no Existe: ", CONVERT(Var_ReferenciaMov, CHAR));
							SET Par_Consecutivo := 'NI';
							LEAVE ManejoErrores;
					END IF;
				END IF;
			END IF;
		END IF; -- END IF de tipo de canal

		SET Entero_Cero	:= 0;

		-- Se inserta la comision por el deposito a cobros pendientes #COBROSPEND#
		IF(Var_Status = Aplicado AND Par_InsertaTabla = Var_SiInserta) THEN
			SELECT IVA INTO Var_IVA
					FROM CLIENTES CL
					INNER JOIN SUCURSALES SUC
					ON  CL.SucursalOrigen = SUC.SucursalID WHERE CL.ClienteID = CliClienteID;

			SET Var_IVA := IFNULL(Var_IVA,Decimal_Cero);

			IF(Var_TipoDeposito = Var_Efectivo)THEN
				SET Var_Comision := (SELECT EfectivoComPend FROM PARAMETROSSIS);
			ELSE
				SET Var_Comision := (SELECT TransferComPend FROM PARAMETROSSIS);
			END IF;

			SET Var_IVA := ROUND(Var_Comision * Var_IVA,2);

			SET Var_Comision := IFNULL(Var_Comision,Decimal_Cero);

			IF(Var_Comision > Decimal_Cero) THEN
				CALL COBROSPENDALT(
					CliClienteID,       Var_CuentaAhoID,    Var_FechaSistema,       Var_Comision,       Var_MovComDepRef,
					Con_DescripTipoMov, Var_NumTransaccion, Var_IVA, 				Salida_NO,     		Par_NumErr,
                    Par_ErrMen, 		Aud_EmpresaID,      Aud_Usuario,        	Aud_FechaActual,    Aud_DireccionIP,
					Aud_ProgramaID,     Aud_Sucursal,       Var_NumTransaccion);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;
			END IF;
		END IF;

		IF(Par_InsertaTabla = Var_SiInserta)THEN
			INSERT INTO DEPOSITOREFERE (
					FolioCargaID,       CuentaAhoID,        NumeroMov,          InstitucionID,      FechaCarga,
					FechaAplica,        NatMovimiento,      MontoMov,           TipoMov,            DescripcionMov,
					ReferenciaMov,      Status,             MontoPendApli,      TipoDeposito,       TipoCanal,
					MonedaId,           EmpresaID,          Usuario,            FechaActual,        DireccionIP,
					ProgramaID,         Sucursal,           NumTransaccion)
			SELECT  Var_FolioOperacion, tmp.CuentaAhoID,    tmp.NumeroMov,      tmp.InstitucionID,  Var_FechaSistema,
					tmp.FechaAplica,    tmp.NatMovimiento,  tmp.MontoMov,       tmp.TipoMov,        tmp.DescripcionMov,
					tmp.ReferenciaMov,  Var_Status,         tmp.MontoPendApli,  tmp.TipoDeposito,   tmp.TipoCanal,
					tmp.MonedaId,       Aud_EmpresaID,      Aud_Usuario,        Aud_FechaActual,    Aud_DireccionIP,
					Aud_ProgramaID,     Aud_Sucursal,       Aud_NumTransaccion
				FROM TMPDEPOSITOS tmp
					WHERE FolioCargaID=Par_Folio;

				SELECT  CuentaAhoID INTO Var_Cuenta
				FROM CUENTASAHOTESO
			WHERE NumCtaInstit = Var_CuentaAhoIDTMP;


			CALL TESORERIAMOVSALT(
					Var_Cuenta,     Fecha_Valida,		Var_MontoMov,     Var_DescripcionMov, Var_ReferenciaMov,
					Cadena_Vacia,   Nat_Abono,          Aplicado,         TipoMovDepRef,      Entero_Cero,
					Salida_NO,      Par_NumErr,         Par_ErrMen,       Var_Consecutivo2,   Aud_EmpresaID,
					Aud_Usuario,    Aud_FechaActual,    Aud_DireccionIP,  Aud_ProgramaID,     Aud_Sucursal,
					Var_NumTransaccion);

			IF (Par_NumErr <> '000') THEN
				IF (Par_Salida = Salida_SI) THEN
					SELECT Par_NumErr AS NumErr,
					Par_ErrMen  AS ErrMen,
					'institucionID' AS control,
					Entero_Cero AS consecutivo;
				END IF;
			ELSE
				CALL SALDOSCTATESOACT(
					Var_CuentaAhoIDTMP,   	Var_InstitucionID,   	Var_MontoMov,       Nat_Abono,          Salida_NO,
					Par_NumErr,     		Par_ErrMen,         	Var_Consecutivo2,   Aud_EmpresaID,      Aud_Usuario,
					Aud_FechaActual,    	Aud_DireccionIP,        Aud_ProgramaID,     Aud_Sucursal,       Var_NumTransaccion);
				IF (Par_NumErr <> '000') THEN
					IF (Par_Salida = Salida_SI) THEN
						SELECT Par_NumErr AS NumErr,
						Par_ErrMen  AS ErrMen,
						'institucionID' AS control,
						Entero_Cero AS consecutivo;
					END IF;
				END IF;
			END IF;

			INSERT INTO DEPREFERENCIADO(
				FolioCargaID,       NumeroMov,		InstitucionID,		CuentaTesoID,		NatMovimiento,
				MontoDeposito,		DescripcionMov,	Estatus,			FechaCarga,			FechaAplica,
				FechaValida,		Referencia,		TipoDeposito,		TipoCanal,			MonedaID,
				EmpresaID,      	Usuario,        FechaActual,		DireccionIP,        ProgramaID,
				Sucursal,			NumTransaccion
			)SELECT
				Var_FolioOperacion,	Aud_NumTransaccion,	tmp.InstitucionID,	tmp.CuentaAhoID,	tmp.NatMovimiento,
				tmp.MontoMov,		tmp.DescripcionMov,	Var_Status,			Var_FechaSistema,	tmp.FechaAplica,
				Fecha_Valida,		tmp.ReferenciaMov,	tmp.TipoDeposito,	tmp.TipoCanal,		tmp.MonedaId,
				Aud_EmpresaID,      Aud_Usuario,        Aud_FechaActual,	Aud_DireccionIP,    Aud_ProgramaID,
				Aud_Sucursal,       Aud_NumTransaccion
			FROM TMPDEPOSITOS tmp
				WHERE FolioCargaID=Par_Folio;
		END IF;

		SET Entero_Cero	:= 0;

		IF(IFNULL(Var_CuentaAhoID, Entero_Cero) <> Entero_Cero)THEN
			SET Var_Status		:=	Aplicado;
		END IF;

		IF(Var_Status = IdentificadoNO AND Par_InsertaTabla = Var_SiInserta) THEN

			SELECT CA.CuentaAhoID, CA.ClienteID, CA.MonedaID
			INTO Var_CuentaConcen, Var_ClienteConcen, Var_MonedaConcen
				FROM CUENTASCONCENTRA CC
					INNER JOIN CUENTASAHO CA ON CC.CuentaAhoID = CA.CuentaAhoID
						WHERE CA.TipoCuentaID = TipoConcentra AND CC.TipoConcentraID = TipoDepositoNI;
			SET Var_CuentaConcen	:= IFNULL(Var_CuentaConcen, Entero_Cero);

			IF(Var_CuentaConcen <> Entero_Cero) THEN
				SET Var_DescripCtaMov	:=	CASE Var_TipoCanal
													WHEN NumCredito 	THEN CONCAT(DescripcionCredito,' NI')
													  WHEN CuentaAhorro 	THEN CONCAT(DescripcionCuenta, ' NI')
													  WHEN NumCliente		THEN CONCAT(DescripcionCliente,' NI')
													  ELSE 'DEPOSITO NI' END;
				SET	Var_RefereCtaCon	:=	CONVERT(Var_CuentaConcen,CHAR);

				CALL MAESTROPOLIZASALT(
					Var_Poliza,         Aud_EmpresaID,    	Fecha_Valida,     	Var_NatAhorro,      Var_ConceptoCon,
					Var_DescripCtaMov, 	Salida_NO,        	Par_NumErr,   		Par_ErrMen,			Aud_Usuario,
                    Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,     Aud_Sucursal,     	Var_NumTransaccion);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				IF(Var_NatAhorro = Nat_Cargo) THEN
					SET Var_Cargos  := Var_MontoMov;
					SET Var_Abonos  := Decimal_Cero;
				ELSE
					SET Var_Cargos  := Decimal_Cero;
					SET Var_Abonos  := Var_MontoMov;
				END IF;

				SELECT		tip.EsCaptacion
					INTO	Var_EsCaptacion
					FROM	CUENTASAHO cta
					INNER JOIN	TIPOSCUENTAS tip ON tip.TipoCuentaID = cta.TipoCuentaID
					WHERE	cta.CuentaAhoID = Var_CuentaConcen
					LIMIT	1;

				SET Var_EsCaptacion	:= IFNULL(Var_EsCaptacion, Salida_NO);

				IF (Var_EsCaptacion = Salida_SI) THEN
					SET Var_CtaContConcent	:= CuentaKuboGlobal;
				ELSE
					SET Var_CtaContConcent	:= Var_CtaPrepago;
				END IF;

				IF(Fecha_Valida < Var_PrimerDiaMes) THEN /* si la fecha de operacion es del mes anterior se insertan movimientos de ahorro en el historico*/

					CALL CUENTASAHOMOVHIALT(/* inserta movimientos en la tabla del historico .- `HIS-CUENAHOMOV`*/
						Var_CuentaConcen,   Aud_NumTransaccion,  Fecha_Valida, 	  	Var_NatAhorro,  Var_MontoMov,
						Var_DescripCtaMov, 	Var_ReferenciaMov,   Var_TipoMovAho, 	Aud_EmpresaID,	Aud_Usuario,
						Aud_FechaActual,    Aud_DireccionIP,     Aud_ProgramaID,	Aud_Sucursal,   Var_NumTransaccion);

					CALL DETALLEPOLIZAALT(
						Aud_EmpresaID,		Var_Poliza,		  Fecha_Valida,		Entero_Uno,		Var_CtaContConcent,
						Var_RefereCtaCon,	Var_MonedaId,	  Var_Cargos,		Var_Abonos,		Var_DescripCtaMov,
						Var_RefereCtaCon,	Procedimiento,	  Entero_Uno,		Cadena_Vacia,	Decimal_Cero,
						Cadena_Vacia,		Salida_NO,		  Par_NumErr,   	Par_ErrMen,		Aud_Usuario,
						Aud_FechaActual,  	Aud_DireccionIP,  Aud_ProgramaID, 	Aud_Sucursal,   Var_NumTransaccion);

					IF(Par_NumErr!=Entero_Cero) THEN
						LEAVE ManejoErrores;
					END IF;

					CALL CONTATESORERIAPRO(
						Entero_Cero,            Var_MonedaId,       Var_InstitucionID,	Var_CuentaBancaria, Entero_Cero,
						Entero_Cero,            Entero_Cero,        Fecha_Valida,		Fecha_Valida,       Var_MontoMov,
						Var_DescripCtaMov,     	Var_RefereCtaCon,  	Var_ClienteConcen,	NoEmitePoliza,      Var_Poliza,
						Var_ConceptoCon,        Entero_Cero,        Var_NatConta,		Var_NO,             Var_CuentaConcen,
						Var_ClienteConcen,      Var_TipoMovAho,     Var_NatAhorro,		Par_NumErr,         Par_ErrMen,
						Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,		Aud_FechaActual,    Aud_DireccionIP,
						Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion);

					IF(Par_NumErr!=Entero_Cero) THEN
						LEAVE ManejoErrores;
					END IF;

				ELSE

					CALL CUENTASAHOMOVALT(
						Var_CuentaConcen,	  	Var_NumTransaccion,		Fecha_Valida,		Var_NatAhorro,		Var_MontoMov,
						Var_DescripCtaMov,		Var_ReferenciaMov,		Var_TipoMovAho,		Par_NumErr,			Par_ErrMen,
						Aud_EmpresaID,      	Aud_Usuario,        	Aud_FechaActual,	Aud_DireccionIP,	Aud_ProgramaID,
						Aud_Sucursal,       	Var_NumTransaccion);

					IF(Par_NumErr!=Entero_Cero) THEN
						LEAVE ManejoErrores;
					END IF;

					CALL DETALLEPOLIZAALT(
						Aud_EmpresaID,		Var_Poliza,		    Fecha_Valida,		Entero_Uno,			Var_CtaContConcent,
						Var_RefereCtaCon,	Var_MonedaId,	    Var_Cargos,			Var_Abonos,	  		Var_DescripCtaMov,
						Var_RefereCtaCon,	Procedimiento,	  	Entero_Uno,			Cadena_Vacia,		Decimal_Cero,
						Cadena_Vacia,		Salida_NO,		    Par_NumErr,     	Par_ErrMen,			Aud_Usuario,
						Aud_FechaActual,  	Aud_DireccionIP,  	Aud_ProgramaID, 	Aud_Sucursal, 		Var_NumTransaccion);

					IF(Par_NumErr!=Entero_Cero) THEN
						LEAVE ManejoErrores;
					END IF;

					CALL CONTATESORERIAPRO(
						Entero_Cero,            Var_MonedaId,       Var_InstitucionID,      Var_CuentaBancaria,     Entero_Cero,
						Entero_Cero,            Entero_Cero,        Fecha_Valida,    		Fecha_Valida,           Var_MontoMov,
						Var_DescripCtaMov,     	Var_RefereCtaCon, 	Var_ClienteConcen,      NoEmitePoliza,          Var_Poliza,
						Var_ConceptoConDep,     Entero_Cero,        Var_NatConta,           Var_NO,        		 	Var_CuentaConcen,
						Var_ClienteConcen,      Var_TipoMovAho,     Var_NatAhorro,          Par_NumErr,             Par_ErrMen,
						Entero_Cero,            Aud_EmpresaID,      Aud_Usuario,            Aud_FechaActual,        Aud_DireccionIP,
						Aud_ProgramaID,         Aud_Sucursal,       Var_NumTransaccion);

					IF(Par_NumErr!=Entero_Cero) THEN
						LEAVE ManejoErrores;
					END IF;

				END IF;
			END IF;

		ELSEIF(Var_Status = Aplicado AND Par_InsertaTabla = Var_NO) THEN

			SELECT CA.CuentaAhoID, CA.ClienteID, CA.MonedaID
					INTO Var_CuentaConcen, Var_ClienteConcen, Var_MonedaConcen
				FROM CUENTASCONCENTRA CC
					INNER JOIN CUENTASAHO CA ON CC.CuentaAhoID = CA.CuentaAhoID
						WHERE CA.TipoCuentaID = TipoConcentra AND CC.TipoConcentraID = TipoDepositoNI;
			SET Var_CuentaConcen	:= IFNULL(Var_CuentaConcen, Entero_Cero);

			IF(Var_CuentaConcen <> Entero_Cero) THEN

				SET	Var_RefereCtaCli	:=	CONVERT(Var_CuentaAhoID, CHAR);
				SET	Var_RefereCtaCon	:=	CONVERT(Var_CuentaConcen,CHAR);
				SET	DesDepositoIdent	:= 	CONCAT(DesDepositoIdent,Fecha_Valida,' IDENTIFICADO');
				SET	Var_DescripCtaMov	:=	'TRASPASO ENTRE CUENTAS POR DEPOSITO NI';

				CALL MAESTROPOLIZASALT(
					Var_Poliza,         Aud_EmpresaID,          Var_FechaSistema,   Var_NatAhorro,      Var_ConceptoCon,
					Var_DescripCtaMov, 	Salida_NO,              Par_NumErr,			Par_ErrMen,			Aud_Usuario,
                    Aud_FechaActual,    Aud_DireccionIP,		Aud_ProgramaID,     Aud_Sucursal,   	Var_NumTransaccion
				);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				-- se hace traspaso entre cuentas. cuenta concentradora
				CALL CUENTASAHOMOVALT(
					Var_CuentaConcen,	Var_NumTransaccion,		Var_FechaSistema,	Nat_Cargo,			Var_MontoMov,
					DesDepositoIdent,	Var_RefereCtaCli,		Var_TipoMovAho,		Par_NumErr,			Par_ErrMen,
					Aud_EmpresaID,      Aud_Usuario,        	Aud_FechaActual,	Aud_DireccionIP,	Aud_ProgramaID,
					Aud_Sucursal,       Var_NumTransaccion
				);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				SET Var_Cargos := Var_MontoMov;
				SET Var_Abonos := Decimal_Cero;

				SELECT		tip.EsCaptacion
					INTO	Var_EsCaptacion
					FROM	CUENTASAHO cta
					INNER JOIN	TIPOSCUENTAS tip ON tip.TipoCuentaID = cta.TipoCuentaID
					WHERE	cta.CuentaAhoID = Var_CuentaConcen
					LIMIT	1;

				SET Var_EsCaptacion	:= IFNULL(Var_EsCaptacion, Salida_NO);

				IF (Var_EsCaptacion = Salida_SI) THEN
					SET Var_CtaContConcent	:= CuentaKuboGlobal;
				ELSE
					SET Var_CtaContConcent	:= Var_CtaPrepago;
				END IF;

				CALL DETALLEPOLIZAALT(
					Aud_EmpresaID,		Var_Poliza,		Var_FechaSistema,	Entero_Uno,			Var_CtaContConcent,
					Var_RefereCtaCon,	Var_MonedaId,	Var_Cargos,			Var_Abonos,			DesDepositoIdent,
					Var_RefereCtaCon,	Procedimiento,	Entero_Uno,			Cadena_Vacia,		Decimal_Cero,
					Cadena_Vacia,		Salida_NO,		Par_NumErr,        	Par_ErrMen,			Aud_Usuario,
					Aud_FechaActual,    Aud_DireccionIP,Aud_ProgramaID,     Aud_Sucursal,       Var_NumTransaccion
				);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				-- Cuenta Eje del cliente
				CALL CUENTASAHOMOVALT(
					Var_CuentaAhoID,	Var_NumTransaccion,		Var_FechaSistema,	Var_NatAhorro,		Var_MontoMov,
					DesDepositoIdent,	Var_RefereCtaCon,		Var_TipoMovAho,		Par_NumErr,			Par_ErrMen,
					Aud_EmpresaID,      Aud_Usuario,        	Aud_FechaActual,	Aud_DireccionIP,	Aud_ProgramaID,
					Aud_Sucursal,       Var_NumTransaccion
				);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				SET Var_Cargos := Decimal_Cero;
				SET Var_Abonos := Var_MontoMov;

				CALL DETALLEPOLIZAALT(
					Aud_EmpresaID,		Var_Poliza,			Var_FechaSistema,	Entero_Uno,			Var_CtaContConcent,
					Var_RefereCtaCli,	Var_MonedaId,		Var_Cargos,			Var_Abonos,			DesDepositoIdent,
					Var_RefereCtaCli,	Procedimiento,		Entero_Uno,			Cadena_Vacia,		Decimal_Cero,
					Cadena_Vacia,		Salida_NO,			Par_NumErr,        	Par_ErrMen,			Aud_Usuario,
					Aud_FechaActual,    Aud_DireccionIP,	Aud_ProgramaID,     Aud_Sucursal,       Var_NumTransaccion
				);

				IF(Par_NumErr!=Entero_Cero) THEN
					LEAVE ManejoErrores;
				END IF;

				CALL CUENTASAHOBLOQNIVPRO(	Var_CuentaAhoID,	Aud_Usuario,		Fecha_Valida,		Salida_NO,			Par_NumErr,
											Par_ErrMen,			Aud_EmpresaID,		Aud_Usuario,		Aud_FechaActual,	Aud_DireccionIP,
											Aud_ProgramaID,		Aud_Sucursal,		Aud_NumTransaccion);

				IF( Par_NumErr <> Entero_Cero ) THEN
					LEAVE ManejoErrores;
				END IF;
			END IF;
		END IF;

		IF Var_InstitucionID = INSTITUCION_CASHIN AND Var_CuentaAhoIDTMP = CUENTA_CASHIN AND Var_Status = Aplicado THEN
			
			SELECT 	CP.Transaccion, 		CP.CantPenAct,		CP.FechaActual,
					CL.PagaIVA, 			CA.SaldoDispon,		CASE CL.PagaIVA WHEN 'S' THEN SC.IVA ELSE 0 END
			INTO 	Var_Transaccion, 		Var_CantPenAct,		Var_FechaActCob,
					Var_PagaIVA,			Var_SaldoDispon,	Var_IVA	
			FROM 	COBROSPEND CP
			INNER JOIN CLIENTES CL
			ON CL.ClienteID = CP.ClienteID
			INNER JOIN CUENTASAHO CA
			ON CA.CuentaAhoID = CP.CuentaAhoID
			INNER JOIN SUCURSALES SC
			ON SC.SucursalID = CL.SucursalOrigen
			WHERE 	CP.ClienteID 	= CliClienteID
			AND 	CP.CuentaAhoID	= Var_CuentaAhoID
			AND 	CP.Fecha 		= Var_FechaSistema
			AND 	CP.Estatus 		= ESTATUS_PENDIENTE
			ORDER BY FechaActual DESC
			LIMIT 1;

			SET Var_CantPenCom	:= Var_CantPenAct + ROUND(Var_CantPenAct * Var_IVA,2);

			IF(Var_SaldoDispon >= Var_CantPenCom OR FNTIPOSMOVSOBREGIRADO(Var_TipoMovCashIn) = 'S') THEN

				SET Var_MontoCob 	:= Var_CantPenAct;

				IF(Var_PagaIVA = CONS_SI)THEN
					SET Var_MontoCobIva := ROUND(Var_CantPenAct * Var_IVA,2);  			
				END IF;

			ELSE 

				IF(Var_PagaIVA = CONS_SI)THEN
					SET Var_MontoCob	:= ROUND((Var_SaldoDispon - ((Var_SaldoDispon/(1+Var_IVA))*Var_IVA)),2);

					SET Var_MontoCobIva := Var_SaldoDispon - Var_MontoCob; 
				ELSE

					SET Var_MontoCob 	:= Var_SaldoDispon;
				END IF;
			END IF;

			SET Var_CantPenCom	:= Var_MontoCob + Var_MontoCobIva;

			CALL COBROSPENAPLICAPRO	(
				CliClienteID,		Var_CuentaAhoID,		Var_FechaSistema,	Var_FechaSistema,		Var_Transaccion,
				Var_MontoCob,		Var_CantPenCom,			Var_MontoCobIva,	DESC_MOV,				DESC_MOV_IVA,
				Var_TipoMovCashIn,	Var_TipoMovIva,			Var_MonedaID,		Aud_Sucursal,			CONCEPTO_CONTA,
				MOV_CONTA,			MOV_CONTA_IVA,			ALTA_POLIZA_NO,		Salida_NO,				Par_NumErr, 
				Par_ErrMen,			Var_Poliza,				Aud_EmpresaID,		Aud_Usuario,			Var_FechaActCob,
				Aud_DireccionIP,	Aud_ProgramaID,			Aud_Sucursal,		Aud_NumTransaccion);

			IF(Par_NumErr!=Entero_Cero) THEN
				LEAVE ManejoErrores;
			END IF;
		END IF;

		DELETE FROM TMPDEPOSITOS WHERE FolioCargaID = Par_Folio AND NumTransaccion = Var_NumTransaccion;

		SET Par_NumErr      := 0;
		SET Par_ErrMen      := CONCAT("Deposito Referenciado Agregado: ", CONVERT(Var_FolioOperacion, CHAR));
		SET Par_Consecutivo := Var_Status;

	END ManejoErrores;

	IF (Par_Salida = Salida_SI) THEN
		SELECT Par_NumErr  AS NumErr,
			   Par_ErrMen  AS ErrMen,
			  'institucionID' AS control,
			  Par_Consecutivo AS consecutivo;
	END IF;

END TerminaStore$$
DELIMITER ;

DELIMITER ;
SET @Par_Base   	:= 'microfin';              -- Nombre de la Base de Datos
SET @Par_Nombre 	:= 'DEPOSITOREFEREPRO';          -- Nombre del Store o Function
SET @Par_Tipo   	:= 'PROCEDURE';              -- Tipo del Objeto 'FUNCTION' o 'PROCEDURE'
SET @Par_Desc   	:= 'SE AGREGA SECCION PARA COBRO INMEDIATO DE COMISION DE DEPOSITO CASH IN, ASI COMO LAS DESCRIPCIONES DE LOS MOVIMIENTOS DE COMISION'; -- Motivo de la Actualización
SET @Par_Usuario	:= 183;                  -- UsuarioID Personal de quién libera

CALL CONTROLCAMBIOSALT(@Par_Base, @Par_Nombre, @Par_Tipo, FNFOLIONUEVAVERSION(@Par_Base, @Par_Nombre, @Par_Tipo), @Par_Desc, 'N', @Par_NumErr, @Par_ErrMen,
             @Par_Usuario, '0.0.0.0', 'LIBERACION KUBO');