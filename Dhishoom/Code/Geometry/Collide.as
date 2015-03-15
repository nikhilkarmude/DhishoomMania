package Code.Geometry
{
	import Code.System.*;
	import Code.Maths.*;
	import Code.Geometry.*;
	import Code.Characters.Character;
	import Code.Level.*;
	import Code.eTileTypes;
	import Code.Platformer;
	import Code.Constants;
	
	public class Collide
	{
		/// <summary>
		/// Helper function which checks for internal edges
		/// </summary>	
		static private function IsInternalCollision( tileI:int, tileJ:int, normal:Vector2, map:Map ):Boolean
		{
			var nextTileI:int = tileI+normal.m_x;
			var nextTileJ:int = tileJ+normal.m_y;
			
			var currentTile:uint = map.GetTile( tileI, tileJ );
			var nextTile:uint = map.GetTile( nextTileI, nextTileJ );
			
			var internalEdge:Boolean = Map.IsTileObstacle(nextTile);
						
			return internalEdge;
		}
		
		/// <summary>
		/// Returns information about distance and direction from point to AABB
		/// </summary>
		static public function AabbVsAabbInternal( delta:Vector2, aabbCentre:Vector2, aabbHalfExtents:Vector2, point:Vector2, outContact:Contact ):Boolean
		{
			// form the closest plane to the point
			var planeN:Vector2 = delta.m_MajorAxis.NegTo();
			var planeCentre:Vector2 = planeN.Mul( aabbHalfExtents ).AddTo(aabbCentre);
			
			// distance point from plane
			var planeDelta:Vector2 = point.Sub( planeCentre );
			var dist:Number = planeDelta.Dot( planeN );
			
			// form point
			
			
			// build and push
			outContact.Initialise( planeN, dist, point );
				
			// collision?
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function AabbVsAabb( a:IAABB, b:IAABB, outContact:Contact, tileI:int, tileJ:int, map:Map, checkInternal:Boolean=true ):Boolean
		{
			var combinedExtentsB:Vector2 = Platformer.m_gTempVectorPool.AllocateClone( b.m_HalfExtents ).AddTo(a.m_HalfExtents);
			var combinedPosB:Vector2 = b.m_Centre;
			
			var delta:Vector2 = combinedPosB.Sub(a.m_Centre);
			
			AabbVsAabbInternal( delta, combinedPosB, combinedExtentsB, a.m_Centre, outContact );
			
			//
			// check for internal edges
			//
			
			if ( checkInternal )
			{
				return !IsInternalCollision( tileI, tileJ, outContact.m_normal, map );
			}
			else 
			{
				return true;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function PointInAabb( point:Vector2, aabb:AABB ):Boolean
		{
			var delta:Vector2 = point.Sub( aabb.m_Centre );
			
			return	Math.abs(delta.m_x) < aabb.m_HalfExtents.m_x &&
					Math.abs(delta.m_y) < aabb.m_HalfExtents.m_y;
		}
		
		/// <summary>
		/// Only collide with the top plane of Aabb b
		/// </summary>
		static public function AabbVsAabbTopPlane( a:IAABB, b:IAABB, outContact:Contact, tileI:int, tileJ:int, map:Map ):Boolean
		{
			var collideAabb:Boolean = AabbVsAabb( a, b, outContact, tileI, tileJ, map, false );
			if ( collideAabb )
			{
				// these conditions ensure that we only collide with the top plane, and that we have to be greater than 
				// -Constants.kPlaneHeight away from the surface for this collision to return true
				if ( outContact.m_normal.m_y<0&&outContact.m_dist>=-Constants.kPlaneHeight )
				{
					return true;
				}
			}
			
			return false;
		}
	}
}
