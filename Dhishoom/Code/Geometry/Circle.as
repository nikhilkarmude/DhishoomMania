package Code.Geometry
{
	import flash.geom.Point;
	
	public class Circle
	{
		private var m_pos:Vector2;
		private var m_radius:Number;

		/// <summary>
		/// 
		/// </summary>	
		public function Circle( pos:Vector2, radius:Number )
		{
			m_pos=pos;
			m_radius=radius;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Pos( ):Vector2
		{
			return m_pos;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Pos( p:Vector2 ):void
		{
			m_pos = p;
		}

		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Radius():Number
		{
			return m_radius;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Radius(newRadius:Number):void
		{
			m_radius = newRadius;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function Contains( p:Vector2 ):Boolean
		{
			var radius:Number = m_Radius - Constants.kTouchingThresh;
			return p.Sub(m_pos).m_LenSqr < radius*radius;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function DistanceToPoint( p:Vector2 ):Number
		{
			return p.Sub( m_pos ).m_Len - m_radius;
		}
	
		/// <summary>
		/// 
		/// </summary>	
		public function ClosestPointOnEdge(p:Vector2, bias:Number) : Vector2
		{
			var d:Vector2 = p.Sub(m_pos);
			return d.m_Unit.MulScalar(m_radius-bias).Add(m_pos);
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function ClosestPointAndDistOnEdge( p:Vector2 ) : PointAndDistanceContainer
		{
			var d:Vector2=p.Sub(m_pos);
			
			var distCentre:Number=d.m_Len;
			var penetration:Number=distCentre-m_radius;
			
			if ( distCentre==0 )
			{
				// default
				return new PointAndDistanceContainer( m_pos.Add(new Vector2( m_radius, 0 )), -m_radius );
			}
			
			// generate point on edge
			var poe:Vector2 = d.MulScalar(m_radius/distCentre).AddTo(m_pos);
			
			return new PointAndDistanceContainer(poe, penetration);
		}

		
		/// <summary>
		/// 
		/// </summary>	
		static public function CircleCircleIntersect( a:Circle, b:Circle, pointAOut:Vector2Ref, pointBOut:Vector2Ref ):Boolean
		{
			var d:Vector2=b.m_Pos.Sub( a.m_Pos );
			var centreDist:Number=d.m_Len;
			
			if ( centreDist>a.m_Radius+b.m_Radius )
			{
				// separated
				pointAOut=pointBOut=null;
				return false;
			}
			else 
			{
				// partial intersection
				var r0Sqr:Number=a.m_Radius*a.m_Radius;
				var newCentreDist:Number=( r0Sqr-b.m_Radius*b.m_Radius+centreDist*centreDist )/( 2*centreDist );
				
				var sqr:Number=r0Sqr-newCentreDist*newCentreDist;
				
				if ( sqr<=0.0 )
				{
					// containment
					pointAOut=pointBOut=null;
					return false;
				}
				
				var P2:Vector2=a.m_Pos.Add( d.MulScalar( newCentreDist/centreDist ) );
				var radius:Number=Math.sqrt( sqr );
				
				var perp:Vector2=( b.m_Pos.Sub( a.m_Pos ) ).m_Perp.m_Unit;
				
				pointAOut.m_Value=P2.Add(perp.MulScalar(radius));
				pointBOut.m_Value=P2.Sub(perp.MulScalar(radius));
				
				return true;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function RayCast(start:Vector2, end:Vector2, invert:Boolean):Number
		{
			var delta:Vector2 = start.Sub(m_pos);
			var d:Vector2 = end.Sub(start);

			var a:Number = d.Dot(delta);
			var b:Number = d.m_LenSqr;
			var c:Number = delta.m_LenSqr;

			var roa:Number = a * a - b * (c - m_radius * m_radius);
			if (roa < 0)
			{
				// no intersection
				return -1;
			}
			else if (roa == 0)
			{
				// ray tangent to circle, one intersection
				var num:Number = Math.sqrt(roa);

				var t0:Number = (-a + num) / b;
				return t0;
			}
			else
			{
				// two intersection points
				num = Math.sqrt(roa);

				t0 = (-a + num) / b;
				var t1:Number = (-a - num) / b;

				if (invert)
				{
					return Math.min(t1, t0);
				}
				else
				{
					return t0;
				}
			}
		}
	}
}
