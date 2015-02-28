package
{
	import flash.geom.Point;

	public class Animal
	{
		
		private static const VELOCITY_MULTIPLIER:Number = 0.1;
		private static const STEERING_MULTIPLIER:Number = 0.08;
		private static const WEIGHT_MULTIPLIER:Number = 0.1;
		private static const SIGHT_MULTIPLIER:Number = 0.001;
		private static const WEIGHT_DAMAGE_CONSTANT:Number = 0.5;
		
		protected const WEIGHT_COEFFICIENT:Number = 1;
		protected const SLOWING_RADIUS:Number = 10;
		
		public var m_position:Point;
		public var m_velocity:Point;
		public var m_target:Point;
		
		public var m_maxSpeed:Number;
		public var m_maxForce:Number;
		
		public var m_weight:Number;
		public var m_randomDirectionChange:Number;
		public var m_sight:Number;
		
		public var m_energy:Number;
		public var m_maxEnergy:Number;
		public var m_energyLosing:Number
		
		public var m_health:Number;
		public var m_maxHealth:Number;
		
		public var m_matingThreshold:Number;
		
		public var selected:Boolean = false;
		public var m_numChildren:int = 0;
		
		public function Animal()
		{
		}
		
		public function calculateBMR():Number
		{
			return m_weight*WEIGHT_MULTIPLIER + m_sight*SIGHT_MULTIPLIER;
		}
		
		public function updateEnergy():void
		{
			m_energyLosing += calculateBMR();
			
			m_energy -= m_energyLosing;
			m_energyLosing = 0;
		}
		
		
		public function updatePosition():void
		{
			m_position = m_position.add(m_velocity);
		}
		
		
		
		public function updateVelocity(randomDirectionChange:Number):void
		{
			m_velocity = getNewVelocity(randomDirectionChange);
			m_energyLosing += m_velocity.length*VELOCITY_MULTIPLIER;
		}
		
		
		public function getNewVelocity(randomDirectionChange:Number):Point
		{
			// returns the next velocity using m_target and m_velocity
			var desiredVelocity:Point = getDesiredVelocity(randomDirectionChange);
			var steering:Point = getSteering(desiredVelocity);
			
			
			
			var newVelocity:Point = m_velocity.add(steering);
			truncate(newVelocity,m_maxSpeed);
			
			return newVelocity;
		}
		
		protected function getSteering(desiredVelocity:Point):Point
		{
			// returns the steering vector to add to the velocity vector, given desired velocity
			var distance:Number = desiredVelocity.length;
			if (distance < SLOWING_RADIUS)
			{
				desiredVelocity.normalize(m_maxSpeed*distance/SLOWING_RADIUS);
			}else{
				desiredVelocity.normalize(m_maxSpeed);
			}
			
			var steering:Point = desiredVelocity.subtract(m_velocity);
			truncate(steering,m_maxForce);
			
			m_energyLosing += steering.length*STEERING_MULTIPLIER;
			
			divide(steering,m_weight*WEIGHT_COEFFICIENT);
			
			return steering;
		}
		
		protected function adjustDesiredVelocity(desiredVelocity:Point, 
												 alignmentVector:Point, alignment:Number, 
												 cohesionVector:Point, cohesion:Number, 
												 separationVector:Point, separation:Number):Point
		{
			
			
			
			
			
			return desiredVelocity;
		}
		
		protected function getDesiredVelocity(randomRadians:Number):Point
		{
			// returns the vector pointing to m_target ± up to randomRadians in angle
			
			
			
			
			var desiredVelocity:Point = m_target.subtract(m_position);
			var distance:Number = desiredVelocity.length;
			
			var angle:Number = Math.atan2(desiredVelocity.y,desiredVelocity.x);
			angle += (Math.random()*2-1)*randomRadians;
			
			desiredVelocity = new Point(Math.cos(angle),Math.sin(angle));
			desiredVelocity.normalize(distance);
			
			return desiredVelocity;
		}
		
		
		protected function truncate(p:Point, n:Number):void
		{
			if (p.length > n)
			{
				p.normalize(n);
			}
		}
		
		protected function divide(p:Point, n:Number):void
		{
			p.x = p.x/n;
			p.y = p.y/n;
		}
		
		protected function multiply(p:Point, n:Number):void
		{
			p.x = p.x*n;
			p.y = p.y*n;
		}
	
		protected function inSight(p:Point):Boolean
		{
			// returns true if the other animal is in sight, false otherwise
			if (m_position.subtract(p).length <= m_sight)
			{
				return true;
			}else{
				return false;
			}
		}
		
		public function samePosition(p1:Point, p2:Point, n:Number):Boolean
		{
			if (Math.abs(p1.subtract(p2).length) < n)
			{
				return true;
			}else{
				return false;
			}
		}
		
		public function attack(other:Animal):Number
		{
			var chanceOfHitting:Number = m_weight/(m_weight+other.m_weight);
			if (Math.random() < chanceOfHitting)
			{
				var maxDamage:Number = m_weight*WEIGHT_DAMAGE_CONSTANT;
				var damage:Number = maxDamage/2 + Math.random()*maxDamage/2;
				return damage;
			}else{
				return 0;
			}
		}
		
		public function offScreen(p:Point):Boolean
		{
			if (p.x > 800 || p.x < 0 || p.y > 600 || p.y < 0)
			{
				return true;
			}else{
				return false;
			}
		}
		
		
		
	}
}