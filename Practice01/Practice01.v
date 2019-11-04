module	carWarning(Warning, DoorClose, Ignition, SeatBelt);

	output		Warning			;

	input		DoorClose		;
	input		Ignition		;
	input		SeatBelt		;

	wire		DoorOpened		;
	wire		NoSeatBelt		;

	wire		Node1			;
	wire		Node2			;

	not		NOT_U0(DoorOpened, DoorClose)		;
	not		NOT_U1(NoSeatBelt, SeatBelt)		;

	and		AND_U0(Node1, DoorOpened, Ignition)	;
	and		AND_U1(Node2, NoSeatBelt, Ignition)	;

	or		OR_U0(Warning, Node1, Node2)		;

endmodule	