global class QE_ScheduleRoomingListGuestBlank implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        QE_RoomingListGuestBlank roomingListGuestMissing = new QE_RoomingListGuestBlank();
   
        Database.executebatch(roomingListGuestMissing, 100);
    }
}