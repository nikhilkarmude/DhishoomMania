package Code.Level
{
	
	public class Room
	{
		private var m_leftDoorExit:Room;
		private var m_rightDoorExit:Room;
		private var m_topDoorExit:Room;
		private var m_bottomDoorExit:Room;
		
		public function Room( leftDoorExit:Room, rightDoorExit:Room, topDoorExit:Room, bottomDoorExit:Room )
		{
			m_leftDoorExit = leftDoorExit;
			m_rightDoorExit = rightDoorExit;
			m_topDoorExit = topDoorExit;
			m_bottomDoorExit = bottomDoorExit;
		}
	}
}
