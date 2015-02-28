package
{
	import flash.geom.Point;

	public class Predator extends Animal
	{
		
		private static const MATING_ENERGY:Number = 700;
		private static const MATING_THRESHOLD:Number = 800;
		private static const STARTING_ENERGY:Number = 700;
		private static const EAT_ENERGY:Number = 25;
		
		private var m_targetPrey:Prey;
		
		public function Predator(position:Point, maxSpeed:Number, maxForce:Number, weight:Number, randomDirectionChange:Number, sight:Number, maxEnergy:Number, maxHealth:Number)
		{
			m_position = position;
			m_maxSpeed = maxSpeed;
			m_maxForce = maxForce;
			m_weight = weight;
			m_randomDirectionChange = randomDirectionChange;
			m_sight = sight;
			m_maxEnergy = maxEnergy;
			m_maxHealth = maxHealth;
			
			m_energy = STARTING_ENERGY;
			m_energyLosing = 0;
			
			m_health = m_maxHealth;
			
			m_velocity = new Point(0,0);
			m_target = m_position;
			m_targetPrey = null;
			
		}
		
		public function decideNextMove(prey_animals:Array, predator_animals:Array, bushes:Array):void
		{
			
			
			
			// CHECK IF WE CAN MATE
			if (m_energy >= MATING_THRESHOLD)
			{
				
				var closestMate:Predator = null;
				var closestMateDistance:Number = -1;
				for each (var mate:Predator in predator_animals)
				{
					if (inSight(mate.m_position) && mate.m_energy >= MATING_THRESHOLD && mate != this)
					{
						if (m_position.subtract(mate.m_position).length < closestMateDistance || closestMateDistance < 0)
						{
							closestMate = mate;
							closestMateDistance = m_position.subtract(mate.m_position).length;
						}
					}
				}
				
				if (closestMate != null)
				{
					if (samePosition(m_position,closestMate.m_position,6))
					{
						m_energy -= MATING_ENERGY;
						m_numChildren++;
						if (Math.random() < 0.5)
						{
							// make baby
							
							predator_animals.push(new Predator(m_position,m_maxSpeed,m_maxForce,m_weight,m_randomDirectionChange,m_sight,m_maxEnergy,m_maxHealth));
						}
					}
					
					m_target = closestMate.m_position;
					updateVelocity(0);
					return;
				}
			}
			
			
			
			// CHECK IF ANY FOOD IS NEAR
			
			var closestDistance:Number = -1;
			for each (var prey:Prey in prey_animals)
			{
				if (inSight(prey.m_position))
				{
					if (m_position.subtract(prey.m_position).length < closestDistance || closestDistance < 0)
					{
						m_targetPrey = prey;
						closestDistance = m_position.subtract(prey.m_position).length;
					}
				}
			}
			
			
			// AM I CHASING PREY?
			if (m_targetPrey != null && inSight(m_targetPrey.m_position) && m_targetPrey.m_health > 0)
			{
				
				if (samePosition(m_position,m_targetPrey.m_position,6))
				{
					eat(m_targetPrey);
				}else{
					chase(m_targetPrey);
				}
				
				return;
			}
			
			
			
			// WANDER
			
			if (samePosition(m_position, m_target,3))
			{
				m_target = new Point(Math.random()*800,Math.random()*600);
				updateVelocity(0);
				return;
			}
			
			
			// KEEP WANDERING
			
			updateVelocity(0);
			return;
			
			
		}
		
		private function chase(prey:Prey):void
		{
			m_target = prey.m_position.add(prey.m_velocity);
			updateVelocity(0);
		}
		
		private function eat(prey:Prey):void
		{
			var damage:Number = attack(prey);
			if (damage > 0)
			{
				m_energy += EAT_ENERGY;
				if (m_energy > m_maxEnergy)
				{
					m_energy = m_maxEnergy;
				}
				prey.m_health -= damage;
			}
			
			m_target = prey.m_position;
			updateVelocity(0);
		}
		
		
		
		
		private function flee(position:Point):void
		{
			var temp:Point = m_position.subtract(position);
			temp.normalize(10*m_maxSpeed);
			m_target = m_position.add(temp);
			
			updateVelocity(m_randomDirectionChange);
		}
	}
}