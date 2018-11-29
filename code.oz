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
         [] note(name:N octave:O sharp:S duration:D instrument:I) then H|{ChordToExtended }
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
   
   
      
