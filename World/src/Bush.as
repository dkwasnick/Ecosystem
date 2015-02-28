package
{
	import flash.geom.Point;

	public class Bush
	{
		public var m_position:Point;
		public var m_foodLeft:Number;
		public var m_foodLosing:Number;
		
		
		public function Bush(p:Point, food:Number)
		{
			m_position = p;
			m_foodLeft = food;
			m_foodLosing = 0;
			
		}
		
		public function updateFood():void
		{
			m_foodLeft -= m_foodLosing;
			m_foodLosing = 0;
		}
	}
}