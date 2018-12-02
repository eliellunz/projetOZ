local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      fun{ToExtend Partition}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animaux/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare
   fun{ToExtend List}
      case List of H|T then case H of silence(duration:D) then H|{ToExtend T}
         [] Atom then {NoteToExtend H}|{ToExtend T}
         [] Name#octave then {NoteToExtend H}|{ToExtend T}
         [] note(name:N octave:O sharp:S duration:D instrument:I) then H|{ToExtend T}
         [] H1|T1 then {ChordToExtend H}|{ToExtend T}
         [] duration(seconds:D L) then {Duration H.seconds {ToExtend H.1}}|{ToExtend T}
         [] stretch(factor:F L) then {Stretch H.factor {ToExtend H.1}}|{ToExtend T}
         [] drone(note:N amount:A) then {Drone {ToExtend H.note} H.amount}|{ToExtend T}
         [] transpose(semitones:S L) then {Transpose H.semitones {ToExtend H.2}}|{ToExtend T}
         else {ToExtend T}
         end
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare
   fun {Reverse Music Acc} %music=liste
      case Music of nil then Acc
      [] H|T then {Reverse T H|Acc}
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare
      fun{Repeat N Music Acc}  
         if N>=1 then {Repeat N-1 Music Music|Acc}
         else Acc
         end
      end 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare 
   fun{ChordToExtended Chord}
      case Chord of nil then nil 
      [] H|T then case H of Atom then {ChordToExtended H}|{ChordToExtended T}
         []Name#octave then {ChordToExtended H}|{ChordToExtended T}
			[] note(name:N octave:O sharp:S duration:D instrument:I) then H|{ChordToExtended T}
         else nil
         end
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare
   fun{Drone Item A}
      if A=<0 then nil
      else Item|{Drone item A-1}
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   declare E in
   fun{Stretch Factor List}
      case List of nil then nil
      [] H|T then case H of note(name:N octave:O sharp:S duration:D instrument:I) then E=H.duration H.duration=E*Factor H|{Stretch Factor T}
         [] H1|T1 then {Stretch Factor H}|{Stretch Factor T}
         [] silence(duration:D) then E=H.duration H.duration=E*Factor H|{Stretch Factor T}
         [] duration(seconds:D L) then {Stretch Factor {Duration H.seconds H.1}}|{Stretch Factor T}
         [] stretch(factor:F L) then {Stretch Factor {Stretch H.factor H.1}}|{Stretch Factor T}
         [] drone(note:N amount:A) then {Stretch Factor {Drone H.note H.amount}}|{Stretch Factor T}
         [] transpose(semitones:S L) then {Stretch Factor {Transpose H.semitones H.1}}|{Stretch Factor T}
         else nil
         end
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
  declare
   fun{Up Note A}
      E=Note.octave
	if A>=1 then 
         if Note.name=='c' then Note.sharp=true {Up Note A-1}
         else if Note.name=='c' andthen Note.sharp==true then Note.sharp=false Note.name='d' {Up Note A-1}
            else if Note.name=='d' then Note.sharp=true {Up Note A-1}
               else if Note.name=='d' andthen Note.sharp==true then Note.sharp=false Note.name='e' {Up Note A-1}
                  else if Note.name=='e' then Note.name='f' {Up Note A-1}
                     else if Note.name=='f' then Note.sharp=true {Up Note A-1}
                        else if Note.name=='f' andthen Note.sharp==true then Note.sharp=false Note.name='g' {Up Note A-1}
                           else if Note.name=='g' then Note.sharp=true {Up Note A-1}
                              else if Note.name=='g' andthen Note.sharp==true then Note.sharp=false note.name='a' {Up Note A-1}
                                 else if Note.name=='a' then Note.sharp=true {Up Note A-1}
                                    else if Note.name=='a' andthen Note.sharp==true then Note.sharp=false Note.name='b' {Up Note A-1}
					 else if Note.name=='b' then Note.name='c' Note.octave=E+1 {Up Note A-1}
					      end
					    end
                                    end
                                 end
                              end
                           end
                        end
                     end
                  end
               end
            end
         end
	if A<=-1 then if Note.name=='b' then Note.name='a' Note.sharp=true {Up Note A+1}
         else if Note.name=='a' andthen Note.sharp==true then Note.sharp=false {Up Note A+1}
            else if Note.name=='a' then Note.sharp=true Note.name='g' {Up Note A+1}
               else if Note.name=='g' andthen Note.sharp==true then Note.sharp=false {Up Note A+1}
                  else if Note.name=='g' then Note.name='f' Note.sharp=true {Up Note A+1}
		     else if Note.name=='f' andthen Note.sharp=true then Note.sharp=false {Up Note A+1}
                        else if Note.name=='f' then Note.name='e' {Up Note A+1}
                           else if Note.name=='e' then Note.sharp=true Note.name='d' {Up Note A+1}
                              else if Note.name=='d' andthen Note.sharp==true then Note.sharp=false {Up Note A+1}
                                 else if Note.name=='d' then Note.sharp=true Note.name='c' {Up Note A+1}
                                    else if Note.name=='c' andthen Note.sharp==true then Note.sharp=false {Up Note A+1}
					 else if Note.name=='c' then Note.name='b' Note.octave=E-1{Up Note A+1} 
					      end
					    end
                                    end
                                 end
                              end
                           end
                        end
                     end
                  end
               end
            end
         end
      end
   end
   
   
   declare
   fun{Transpose N List}
	 case List of H|T then case H of H1|T1 then {Transpose N H}|{Transpose N T}
         [] note(name:N octave:O sharp:S duration:D instrument:I) then {Up H N}|{Transpose N T}
         []silence(duration:D) then H|{Transpose N T}
         [] duration(seconds:D L) then {Transpose N {Duration H.seconds H.1}}|{Transpose N T}
         [] stretch(factor:F L) then {Transpose N {Stretch H.factor H.1}}|{Transpose N T}
         [] drone(note:N amount:A) then {Transpose N {Drone H.note H.amount}}|{Transpose N T}
         [] transpose(semitones:S L) then {Transpose N {Transpose H.semitones H.1}}|{Transpose N T}
         else nil
         end
       end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 declare
   fun{Duree Partition Acc}
      case Partition of H|T then case H of note(name:N octave:O sharp:S duration:D instrument:I) then {Duree T Acc+H.duration}
	                                     []H1|T1 then {Duree H1 Acc}
	                                     else nil
	                                     end
      [] note(name:N octave:O sharp:S duration:D instrument:I) then Partition.duration
      else nil
      end
   end

	    
   declare 
   fun{Duration Seconds Partition}
      local
         Fact=T/{Duree Partition nil}
      in
         {Stretch Fact Partition}
      end
   end
		
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
 declare 
		fun {Merge P2T List}
			case List of H|T then case H of Fact#Music then 
					{Sum {Map {Mix P2T H} fun{$ X} X*Fact end} {Merge P2T T}}
				else nil end
			else end
		end
		
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		declare
		fun {Sum L1 L2}
			case L1#L2 of (H1|T1)#(H2|T2) then H1+H2|{Sum T1 T2}
			[] (H1|T1)#nil then H1|{Sum T1 nil}
			[] nil#(H2|T2) then H2|{Sum nil T2}
			else nil 
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		declare
		fun {Cut D F Music}
			local Deb=44100.0*D
			      Fin=44100.0*F
			in
			case Music of H|T then if Deb<0.0 then 0.0|{Cut Deb+1.0 Fin H|T}
					else if Deb==Fin then H|nil
						else H|{Cut Deb+1.0 Fin T}
						end
					end
				[] nil then if Deb==Fin then nil
					else 0.0|{Cut Deb+1.0 Fin nil}
					end
				end
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
		declare 
		fun {Fade S O Music}
			Start=44100.0*S
			Out=44100.0*O
			Len={IntToFloat {Lenght Music}}
			local fun {Fade2 X Music}
				case Music of H|T then if X=<Start then H*((X-1)/(Start))|{Fade2 X+1.0 T}
						else if X>Start andthen X<(Len-Out) then H|{Fade2 X+1.0 T}
							else H*((Len-X)/Out)|{Fade2 X+1.0 T} 
							end
						end
					[] nil then nil 
					else nil
					end
				end
			in
			{Fade2 0.0 Music}
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		declare
		fun {Echo D F Music}
			Delay=D*44100.0
			local fun {MusicWD Delay Music Acc}
					if Delay>0.0 then 0.0|{MusicWD Delay-1.0 Music Acc}
					else case Music of H|T then H|{MusicWD Delay T Acc}
						else Acc 
						end
					end
				end
			in
				{Merge P2T [ F#{MusicWD Delay Music nil} 1#Music]} %% j'ai mis 1 comme fact de music car pas clair, a verif
			end
		end
		
		
		
		
		
		
