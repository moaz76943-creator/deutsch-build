/// Task 1605: Assigns rooms to semantic domains (Kitchen -> food, Library -> abstract)
class RoomThematicAssigner {
  String getAssignedRoom(String domain) => domain == 'food' ? 'KITCHEN' : (domain == 'science' ? 'LABORATORY' : 'STUDY_HALL');
}
