package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	[SWF(width='800',height='600',backgroundColor='#ffffff',frameRate='30')]
	
	public class World extends Sprite
	{
		
		private static const SELECTED_COLOR:uint = 0xCC0000;
		private static const PREY_COLOR:uint = 0x0000FF;
		private static const PREDATOR_COLOR:uint = 0xFF3333;
		private static const BUSH_COLOR:uint = 0x00DD00;
		private static const OUTLINE_COLOR:uint = 0x000000;
		
		private var prey_animals:Array = new Array();
		private var predator_animals:Array = new Array();
		public var bushes:Array = new Array();
		
		
		private var tf:TextField;
		private var tf2:TextField;
		private var prevTime:int;
		private var fpsIndex:int;
		
		public function World()
		{
			
			prevTime = getTimer();
			fpsIndex=0;
			
			tf = new TextField();
			addChild(tf);
			tf2 = new TextField();
			tf2.x = 600;
			tf2.width = 200;
			addChild(tf2);
			
			
			for (var i:int = 0; i<100; i++)
			{
				prey_animals.push(new Prey(randomPoint(),Math.random()*2+4,Math.random()+1.5,Math.random()+1.5,Math.random(),Math.random()*30+85,1000,10));
			}
			
			for (i = 0; i<10; i++)
			{
				predator_animals.push(new Predator(randomPoint(),Math.random()*2+5,Math.random()*2+3,Math.random()*2+3,0,Math.random()*30+120,2000,10));
			}
			
			for (i=0; i<10; i++)
			{
				bushes.push(new Bush(randomPoint(),50));
			}
			
			
			
			
			stage.addEventListener(MouseEvent.CLICK,clickListener);
			this.addEventListener(Event.ENTER_FRAME,enterFrameListener);
		}
		
		
		protected function randomPoint():Point
		{
			return new Point(Math.random()*800,Math.random()*600);
		}
		
		protected function clickListener(me:MouseEvent):void
		{
			var closestAnimal:Animal = null;
			var closestDistance:Number = -1;
			for each (var prey:Animal in prey_animals)
			{
				prey.selected = false;
				if (prey.m_position.subtract(new Point(mouseX,mouseY)).length < closestDistance || closestDistance < 0)
				{
					closestAnimal = prey;
					closestDistance = prey.m_position.subtract(new Point(mouseX,mouseY)).length;
				}
			}
			
			for each (var pred:Animal in predator_animals)
			{
				pred.selected = false;
				if (pred.m_position.subtract(new Point(mouseX,mouseY)).length < closestDistance || closestDistance < 0)
				{
					closestAnimal = pred;
					closestDistance = pred.m_position.subtract(new Point(mouseX,mouseY)).length;
				}
			}
			
			if (closestAnimal != null)
			{
				closestAnimal.selected = true;
			}
		}
		
		protected function enterFrameListener(event:Event):void
		{
			
			fpsIndex++;
			if (fpsIndex == 10)
			{
				var fps:int = 10000/(getTimer()-prevTime);
				tf.text = fps+" fps\nPrey: "+prey_animals.length+"\nPredators: "+predator_animals.length+"\nBushes: "+bushes.length;
				prevTime = getTimer();
				fpsIndex = 0;
			}
			
			
			
			graphics.clear();
			
			// GET RID OF DEAD BUSHES
			var updatedBushes:Array = new Array();
			for each (var bush:Bush in bushes)
			{
				bush.updateFood();
				if (bush.m_foodLeft > 0)
				{
					updatedBushes.push(bush);
				}
			}
			bushes = updatedBushes;
			
			// GET RID OF DEAD PREY
			var updatedPrey:Array = new Array();
			for each (var prey:Prey in prey_animals)
			{
				prey.updateEnergy();
				if (prey.m_health > 0 && prey.m_energy > 0)
				{
					updatedPrey.push(prey);
				}
			}
			prey_animals = updatedPrey;
			
			// GET RID OF DEAD PREDATORS
			var updatedPredators:Array = new Array();
			for each (var pred:Predator in predator_animals)
			{
				pred.updateEnergy();
				if (pred.m_health > 0 && pred.m_energy > 0)
				{
					updatedPredators.push(pred);
				}
			}
			predator_animals = updatedPredators;
			
			
			
			
			
			
			graphics.lineStyle(1,OUTLINE_COLOR);
			
			
			for each (bush in bushes)
			{
				
				graphics.beginFill(BUSH_COLOR,1);
				graphics.drawCircle(bush.m_position.x,bush.m_position.y,4);
				graphics.endFill();
				
				
			}
			
			
			for each (prey in prey_animals)
			{
				
				prey.updatePosition();
				
				graphics.beginFill(PREY_COLOR,1);
				graphics.drawCircle(prey.m_position.x,prey.m_position.y,2);
				graphics.endFill();
				
				if (prey.selected)
				{
					graphics.lineStyle(1,SELECTED_COLOR);
					graphics.drawCircle(prey.m_position.x,prey.m_position.y,6);
					graphics.lineStyle(1,OUTLINE_COLOR);
					
					tf2.text = "Energy: "+Math.round(prey.m_energy)+"/"+Math.round(prey.m_maxEnergy);
					tf2.text += "\nHealth: "+Math.round(prey.m_health*10)/10+"/"+Math.round(prey.m_maxHealth*10)/10;
					tf2.text += "\nChildren: "+prey.m_numChildren;
				}
				
				prey.decideNextMove(prey_animals,predator_animals,bushes);
			}
			
			for each (pred in predator_animals)
			{
				
				pred.updatePosition();
				
				graphics.beginFill(PREDATOR_COLOR,1);
				graphics.drawCircle(pred.m_position.x,pred.m_position.y,3);
				graphics.endFill();
				
				if (pred.selected)
				{
					graphics.lineStyle(1,SELECTED_COLOR);
					graphics.drawCircle(pred.m_position.x,pred.m_position.y,6);
					graphics.lineStyle(1,OUTLINE_COLOR);
					
					
					tf2.text = "Energy: "+Math.round(pred.m_energy)+"/"+Math.round(pred.m_maxEnergy);
					tf2.text += "\nHealth: "+Math.round(pred.m_health*10)/10+"/"+Math.round(pred.m_maxHealth*10)/10;
					tf2.text += "\nChildren: "+pred.m_numChildren;
					
				}
				
				pred.decideNextMove(prey_animals,predator_animals,bushes);
			}
			
			
			
			
			
			// CREATE BUSHES
			if (Math.random() < 0.1)
			{
				bushes.push(new Bush(randomPoint(),50));
			}
			
			
			
		}
		
		
		
		
	}
}