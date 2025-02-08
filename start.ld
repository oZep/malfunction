@Character Assets/characters/npc.char

[start]
Hob: Name's Hob.  
Hob: I'm a blacksmith.  
Hob(Determined): You're the new hero in town, right? I might have a job for you.  
Hob(Sad): I lost my sheep.  
Hob(Determined): If you collect all my sheep, I will build you a sword worthy of a hero such as yourself.  

[question_loop]  
Hob: Can you help me collect my sheep?
Hob: ...
-> Yes [target:end]
-> No [target:no]  
-> What does a blacksmith need sheep for? [target:questioned]  

[questioned]  
Hob(Happy): {shake:1}Nothing.{/shake} 
Hob: ...
-> Leave. [target:question_loop]

[no]  
Hob(Happy): {shake:1}Wrong Answer!!!!{/shake} 
Hob: ...
-> Leave. [target:question_loop]

[end]  
Hob(Surprised): Mh. 
Hob: ... (end)