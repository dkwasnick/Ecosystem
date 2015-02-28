package
{
	import flash.geom.Point;

	public class Prey extends Animal
	{
		
		private static const MATING_ENERGY:Number = 400;
		private static const MATING_THRESHOLD:Number = 500;
		private static const STARTING_ENERGY:Number = 500;
		private static const EAT_ENERGY:Number = 25;
		
		public function Prey(position:Point, maxSpeed:Number, maxForce:Number, weight:Number, randomDirectionChange:Number, sight:Number, maxEnergy:Number, maxHealth:Number)
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
			
		}
		
		public function decideNextMove(prey_animals:Array, predator_animals:Array, bushes:Array):void
		{
			
			// CHECK IF ANY PREDATORS ARE NEAR
			
			var closestPredator:Predator = null;
			var closestPredatorDistance:Number = -1;
			var predatorCenterOfMass:Point = new Point(0,0);
			var numberOfPredators:int = 0;
			
			for each (var predator:Predator in predator_animals)
			{
				if (inSight(predator.m_position))
				{
					predatorCenterOfMass = predatorCenterOfMass.add(predator.m_position);
					numberOfPredators++;
					
					if (m_position.subtract(predator.m_position).length < closestPredatorDistance || closestPredatorDistance < 0)
					{
						closestPredator = predator;
						closestPredatorDistance = m_position.subtract(predator.m_position).length;
					}
				}
			}
			
			if (numberOfPredators > 0)
			{
				divide(predatorCenterOfMass,numberOfPredators);
				
				flee(predatorCenterOfMass);
				
				if (samePosition(m_position,closestPredator.m_position,6))
				{
					var damage:Number = attack(closestPredator);
					if (damage > 0)
					{
						closestPredator.m_health -= damage;
					}
				}
				
				
				return;
				
			}
			
			
			// CHECK IF WE CAN MATE
			if (m_energy >= MATING_THRESHOLD)
			{
				
				var closestMate:Prey = null;
				var closestMateDistance:Number = -1;
				for each (var mate:Prey in prey_animals)
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
						if (Math.random() < 0.6)
						{
							// make baby
							
							prey_animals.push(new Prey(m_position,m_maxSpeed,m_maxForce,m_weight,m_randomDirectionChange,m_sight,m_maxEnergy,m_maxHealth));
						}
					}
					
					m_target = closestMate.m_position;
					updateVelocity(0);
					return;
				}
			}
			
			
			// CHECK IF ANY FOOD IS NEAR
			
			var closestBush:Bush = null;
			var closestDistance:Number = -1;
			for each (var bush:Bush in bushes)
			{
				if (inSight(bush.m_position))
				{
					if (m_position.subtract(bush.m_position).length < closestDistance || closestDistance < 0)
					{
						closestBush = bush;
						closestDistance = m_position.subtract(bush.m_position).length;
					}
				}
			}
			
			if (closestBush != null)
			{
				if (samePosition(m_position,closestBush.m_position,6) && m_velocity.length < 0.5)
				{
					// Already at the bush
					//m_velocity = new Point(0,0);
					eat(closestBush);
					return;
				}else{
					// Not at the bush yet
					goEat(closestBush);
					return;
				}
				
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
		
		private function eat(bush:Bush):void
		{
			m_energy += EAT_ENERGY;
			if (m_energy > m_maxEnergy)
			{
				m_energy = m_maxEnergy;
			}
			bush.m_foodLosing++;
		}
		
		private function goEat(bush:Bush):void
		{
			m_target = bush.m_position;
			updateVelocity(0);
		}
		
		private function flee(position:Point):void
		{
			var temp:Point = m_position.subtract(position);
			temp.normalize(10*m_maxSpeed);
			m_target = m_position.add(temp);
			
			
			if (offScreen(m_target))
			{
				findAlternativeOnScreen();
			}
			
			
			updateVelocity(m_randomDirectionChange);
		}
		
		private function findAlternativeOnScreen():void
		{
			var proposedVector:Point = m_target.subtract(m_position);
			
			var vectorLeft:Point = proposedVector;
			var numberLeft:int = 0;
			while (offScreen(m_position.add(vectorLeft)))
			{
				numberLeft ++;
				vectorLeft = rotate(vectorLeft,1);
			}
			
			var vectorRight:Point = proposedVector;
			var numberRight:int = 0;
			while (offScreen(m_position.add(vectorRight)))
			{
				numberRight ++;
				vectorRight = rotate(vectorRight,-1);
			}
			
			if (numberLeft < numberRight)
			{
				m_target = m_position.add(vectorLeft);
			}else{
				m_target = m_position.add(vectorRight);
			}
			
		}
		
		private function rotate(p:Point, direction:int):Point
		{
			var distance:Number = p.length;
			var angle:Number = Math.atan2(p.y,p.x);
			
			angle += direction*Math.PI/4;
			p = new Point(Math.cos(angle),Math.sin(angle));
			p.normalize(distance);
			return p;
		}
		
		
	}
	
	
}