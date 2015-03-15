package Code.Graphics
{
	import flash.display.*;
	import Code.System.Assert;
	import Code.Maths.Scalar;
	import Code.*;
	
	public class AnimationController
	{
		private var m_movieClip:MovieClip;
		private var m_playing:Boolean;
		private var m_stopping:Boolean;
		private var m_stopped:Boolean;
		
		private var m_playingLabel:String;
		private var m_startFrame:int;
		private var m_endFrame:int;
		
		private var m_currentFrame:Number;
		
		private var m_endOfAnimCallback:Function;
		
		private var m_locked:Boolean;
		
		/// <summary>
		/// 
		/// </summary>	
		public function AnimationController( mc:MovieClip, endOfAnimCallback:Function=null )
		{
			m_movieClip = mc;
			m_playing = false;
			m_stopping = false;
			m_stopped = false;
			m_locked = false;
			m_endOfAnimCallback = endOfAnimCallback;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function FindFrameLabel( labelName:String ):FrameLabel
		{
			for (var i:int=0; i<m_movieClip.currentLabels.length; i++)
			{
				var l:FrameLabel = m_movieClip.currentLabels[i];
				if (l.name == labelName)
				{
					return l;
				}
			}
			
			return null;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function PlayLooping(labelName:String):void
		{
			if (!m_locked)
			{
				if (labelName != m_playingLabel || m_stopped)
				{
					var found:Boolean = false;
					for (var i:int=0; i<m_movieClip.currentLabels.length; i++)
					{
						var l:FrameLabel = m_movieClip.currentLabels[i];
						if (l.name == labelName)
						{
							m_startFrame=l.frame;
							found = true;
							break;
						}
					}
					
					if (i<m_movieClip.currentLabels.length-1)
					{
						m_endFrame = m_movieClip.currentLabels[i+1].frame-1;
					}
					else
					{
						m_endFrame = m_movieClip.totalFrames;
					}
							
					m_playingLabel = labelName;
					m_stopped = false;
					GoToAndStop(m_startFrame);
					
					Assert(found, "AnimationController.PlayLooping(): unable to find label " + labelName);
				}
				
				m_playing=true;
				m_stopping=false;
			}
		}
		
	
		/// <summary>
		/// 
		/// </summary>	
		public function PlayOnce( labelName:String ):void
		{
			PlayLooping( labelName );
			StopAtEnd( );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function Update( dt:Number ):void
		{
			if (m_playing)
			{
				var frameStep:Number = dt*Constants.kDesiredFps;
				
				if (int(m_currentFrame+frameStep) > m_endFrame)
				{
					if (!m_stopping)
					{
						GoToAndStop( m_startFrame + (m_movieClip.currentFrame+frameStep)%m_endFrame );
					}
					else if (!m_stopped)
					{
						GoToAndStop( m_endFrame );
						
						m_stopped = true;
							
						if ( m_endOfAnimCallback != null )
						{
							m_endOfAnimCallback( m_playingLabel );
						}
					}
				}
				else
				{
					var cf:Number = m_currentFrame;
					
					var frame:int = int( m_currentFrame+frameStep );
					GoToAndStop( Math.min(frame, m_endFrame) );
					
					m_currentFrame = cf+frameStep;
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function StopAtEnd():void
		{
			m_stopping = true;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function Stop( ):void
		{
			m_movieClip.stop( );
				
			m_playing = false;
			m_stopping = false;
		}

		
		/// <summary>
		/// 
		/// </summary>	
		public function GoToAndStop( frame:Object ):void
		{
			m_movieClip.gotoAndStop( frame );
			
			m_currentFrame = int(frame);
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function NextFrame(frameStep:Number):void
		{
			if ( frameStep>=1 )
			{
				m_movieClip.nextFrame( );
			}
			else 
			{
				Assert( m_movieClip.currentFrame+frameStep<=m_endFrame, "AnimationController.NextFrame(): went past end of anim!" );
				m_movieClip.gotoAndStop( m_movieClip.currentFrame+frameStep );
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Playing( ):String
		{
			if ( m_playing )
			{
				return m_playingLabel;
			}
			else 
			{
				return null;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Stopped( ):Boolean
		{
			return m_stopped;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function set m_Locked( lock:Boolean ):void
		{
			m_locked = lock;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Locked():Boolean
		{
			return m_locked;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function GotoRandomFrameInCurrentAnim( ):void
		{
			GoToAndStop( m_startFrame + Scalar.RandInt( )%(m_endFrame-m_startFrame) );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function GotoAndStopAtFirstFrame( ):void
		{
			GoToAndStop( m_startFrame );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function SetEndOfAnimCallback( action:Function ):void
		{
			m_endOfAnimCallback = action;
		}
	}
}
