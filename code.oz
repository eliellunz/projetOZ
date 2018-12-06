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
      {ToExtend Partition}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{Mix P2T Music}
		case Music of H|T then 
			case H of note(name:N octave:O sharp:S duration:D instrument:I) then {Flatten {NoteToSample H} {Mix P2T T}}
			[] merge(L) then {Flatten {Merge {Mix P2T L}} {Mix P2T T}}
			[] wave(W) then {Flatten {Project.readFile W} {Mix P2T T}}
			[] partition(P) then {Flatten {Mix P2T {PartitionToTimedList P}} {Mix P2T T}}
			[] reverse(M) then {Flatten {Reverse {Mix P2T M} nil} {Mix P2T T}}
			[] repeat(amount:A M) then {Flatten {Repeat A {Mix P2T M} nil} {Mix P2T T}}
			[] loop(duration:D M) then {Flatten {Loop D {Mix P2T M}} {Mix P2T T}}
			[] clip(low:L high:H M) then {Flatten {Clip L H {Mix P2T M}} {Mix P2T T}}
			[] echo(delay:D decay:F M) then {Flatten {Echo D F {Mix P2T M}} {Mix P2T T}}
			[] fade(start:S out:O M) then {Flatten {Fade S O {Mix P2T M}} {Mix P2T T}}
			[] cut(start:S finish:F M) then {Flatten {Cut S F {Mix P2T M}} {Mix P2T T}}
			end
		end
      {Project.readFile 'wave/animaux/cow.wav'}
   end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
   fun{ToExtend List}
      case List of H|T then case H of silence(duration:D) then H|{ToExtend T}
         [] Atom then {NoteToExtended H}|{ToExtend T}
         [] Name#octave then {NoteToExtended H}|{ToExtend T}
         [] note(name:N octave:O sharp:S duration:D instrument:I) then H|{ToExtend T}
	 [] H1|T1 then {ChordToExtended H}|{ToExtend T}
	 [] duration(seconds:D L) then {Append {Duration H.seconds {ToExtend H.1}} {ToExtend T}}
	 [] stretch(factor:F L) then {Append {Stretch H.factor {ToExtend H.1}} {ToExtend T}}
         [] drone(note:N amount:A) then {Drone {ToExtend H.note} H.amount}|{ToExtend T}
	 [] transpose(semitones:S L) then {Append {Transpose H.semitones {ToExtend H.2}} {ToExtend T}}
         else {ToExtend T}
         end
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   fun {Reverse Music Acc} %music=liste
      case Music of nil then Acc
      [] H|T then {Reverse T H|Acc}
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
      fun{Repeat N Music Acc}  
         if N>=1 then {Repeat N-1 Music Music|Acc}
         else Acc
         end
      end 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
   fun{ChordToExtended Chord}
      case Chord of nil then nil 
		[] H|T then case H of Atom then {NoteToExtended H}|{ChordToExtended T}
			[] Name#octave then {ChordToExtended H}|{ChordToExtended T}
			[] note(name:N octave:O sharp:S duration:D instrument:I) then H|{ChordToExtended T}
         else nil
         end
      else nil
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   fun{Drone Item A}
      if A=<0 then nil
      else Item|{Drone Item A-1}
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   local E in
   fun{Stretch Factor List}
      case List of nil then nil
      [] H|T then case H of note(name:N octave:O sharp:S duration:D instrument:I) then note(name:N octave:O sharp:S duration:Factor*D instrument:I)|{Stretch Factor T}
         [] H1|T1 then {Stretch Factor H}|{Stretch Factor T}
         [] silence(duration:D) then silence(duration:D*Factor)|{Stretch Factor T}
	 [] duration(seconds:D L) then {Append {Stretch Factor {Duration H.seconds H.1}} {Stretch Factor T}}
	 [] stretch(factor:F L) then {Append {Stretch Factor {Stretch H.factor H.1}} {Stretch Factor T}}
	 [] drone(note:N amount:A) then {Stretch Factor {Drone H.note H.amount}}|{Stretch Factor T}
	 [] transpose(semitones:S L) then {Append {Stretch Factor {Transpose H.semitones H.1}} {Stretch Factor T}}
         else nil
         end
      else nil
      end
   end
   end


   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
 
 fun{Up Note A}
   local O D in
      O=Note.octave
      D=Note.duration
      if A>=1 then case Note.name of 'c' andthen Note.sharp==false then {Up note(name:'c' octave:O sharp:true duration:D instrument:none) A-1}
		                []'c' andthen Note.sharp==true then {Up note(name:'d' octave:O sharp:false instrument:none duration:D) A-1}
				[]'d' andthen Note.sharp=false then {Up note(name:'d' octave:O sharp:true duration:D instrument:none) A-1}
				[]'d' andthen Note.sharp==true then {Up note(name:'e' octave:O sharp:false duration:D instrument:none) A-1}
				[]'e' then {Up note(name:'f' octave:O sharp:false duration:D instrument:none) A-1}
				[]'f' andthen Note.sharp=false then {Up note(name:'f' octave:O sharp:true duration:D instrument:none) A-1}
				[]'f' andthen Note.sharp==false then {Up note(name:'g' octave:O sharp:false duration:D instrument:none) A-1}
				[]'g' andthen Note.sharp=false then {Up note(name:'g' octave:O sharp:true duration:D instrument:none) A-1}
				[]'g' andthen Note.sharp==true then {Up note(name:'a' octave:O sharp:false duration:D instrument:none) A-1}
				[]'a' andthen Note.sharp==false then {Up note(name:'a' octave:O sharp:true duration:D instrument:none) A-1}
				[]'a' andthen Note.sharp==true then {Up note(name:'b' octave:O sharp:false duration:D instrument:none) A-1}
				[]'b' then {Up note(name:'c' octave:O+1 sharp:false duration:D instrument:none) A-1}
		   else nil
		   end
      else if A=<~1 then case Note.name of 'b' then {Up note(name:'a' octave:O sharp:true instrument:none) A+1}
					[]'a' andthen Note.sharp==true then {Up note(name:'a' octave:O sharp:false duration:D instrument:none) A+1}
					[]'a' andthen Note.sharp==false then {Up note(name:'g' octave:O sharp:true duration:D instrument:none) A+1}
					[]'g' andthen Note.sharp==true then {Up note(name:'g' octave:O sharp:false duration:D instrument:none) A+1}
					[]'g' andthen Note.sharp==false then {Up note(name:'f' octave:O sharp:true duration:D instrument:none) A+1}
					[]'f' andthen Note.sharp==true then {Up note(name:'f' octave:O sharp:false duration:D instrument:none) A+1}
					[]'f' andthen Note.sharp==false then {Up note(name:'e' octave:O sharp:false duration:D instrument:none) A+1}
					[]'e' then {Up note(name:'d' octave:O sharp:true duration:D instrument:none) A+1}
					[]'d' andthen Note.sharp==true then {Up note(name:'d' octave:O sharp:false duration:D instrument:none) A+1}
					[]'d' andthen Note.sharp==false then {Up note(name:'c' octave:O sharp:true duration:D instrument:none) A+1}
					[]'c' andthen Note.sharp==true then {Up note(name:'c' octave:O sharp:false duration:D instrument:none) A+1}
					[]'c' andthen Note.sharp==false then {Up note(name:'b' octave:O-1 sharp:false duration:D instrument:none) A+1}
			 else nil
			 end
	   else Note
	   end
      end
   end
end
      
   
   fun{Transpose N List}
	 case List of H|T then case H of H1|T1 then {Transpose N H}|{Transpose N T}
         [] note(name:N octave:O sharp:S duration:D instrument:I) then {Up H N}|{Transpose N T}
         []silence(duration:D) then H|{Transpose N T}
         [] duration(seconds:D L) then {Append {Transpose N {Duration H.seconds H.1}} {Transpose N T}}
	 [] stretch(factor:F L) then {Append {Transpose N {Stretch H.factor H.1}} {Transpose N T}}
         [] drone(note:N amount:A) then {Transpose N {Drone H.note H.amount}}|{Transpose N T}
	 [] transpose(semitones:S L) then {Append {Transpose N {Transpose H.semitones H.1}} {Transpose N T}}
         else nil
         end
       end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{Duree Partition Acc}
      case Partition of H|T then case H of note(name:N octave:O sharp:S duration:D instrument:I) then {Duree T Acc+H.duration}
	                                     []H1|T1 then {Duree H1 Acc}
	                                     else nil
	                                     end
      [] note(name:N octave:O sharp:S duration:D instrument:I) then Partition.duration
      else nil
      end
   end

	    
    
   fun{Duration Seconds Partition}
      local
         Fact=Seconds/{Duree Partition nil}
      in
         {Stretch Fact Partition}
      end
   end
		
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
 
		fun{Merge List}
			case List of H|T then case H of Fact#Music then 
					{Sum {Map  H fun{$ X} X*Fact end} {Merge T}}
				else nil end
			else nil  end
		end
		
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
		fun {Sum L1 L2}
			case L1#L2 of (H1|T1)#(H2|T2) then H1+H2|{Sum T1 T2}
			[] (H1|T1)#nil then H1|{Sum T1 nil}
			[] nil#(H2|T2) then H2|{Sum nil T2}
			else nil 
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
		fun {Cut D F Music}
			local Deb=44100.0*D
			      Fin=44100.0*F
			in
			case Music of H|T then if Deb<0.0 then 0.0|{Cut Deb+1.0 Fin H|T}
					elseif Deb==Fin then H|nil
						else H|{Cut Deb+1.0 Fin T}
					
					end
				[] nil then if Deb==Fin then nil
					else 0.0|{Cut Deb+1.0 Fin nil}
					end
				end
			end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
		 
		fun {Fade S O Music}
		local	Start=44100.0*S
			Out=44100.0*O
			Len={IntToFloat {Length Music}}
		in	local fun {Fade2 X Music}
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
			{Fade2 1.0 Music}
			end
		   end
		end
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
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
				{Merge [ F#{MusicWD Delay Music nil} 1#Music]}
			end
		end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		fun{Hauteur Note}
			local Height= height(a:0.0 b:2.0 c:3.0 d:5.0 e:7.0 f:8.0 g:11.0)
				HeightS= heightsharp(a:1.0 c:4.0 d:6.0 f:9.0 g:10.0)
				Nom= Note.name
			in
				if Note.sharp== false then Height.Nom
				else HeightS.Nom
				end
			end
		end
 		
		fun{Freq Item} 
			local Fact Oct={IntToFloat Item.octave}
			in 
				case {Label Item} of 'note' then Fact={Number.pow 2.0 (({IntToFloat Item.octave})-4.0)} 
					({Number.pow 2.0 {Hauteur Item}/12.0})*440.0*Fact
				else case Item of H|T then {Freq H}+{Freq T}
						else 0.0 
					end
				end
			end
		end
		
		fun{NoteToSample Note}
		   case Note of nil then nil else
		      local
		      Pi={Acos ~1.0}
		      Duree=44100.0*Note.duration
		      fun{NToSample Acc}
			 if (Acc=<Duree) then
			    0.5*{Sin 2.0*Pi*{Freq Note}*Acc/44100.0}|{NToSample Acc+1.0}
			 else nil
			 end
		      end
		      end
		   in
		      {NToSample 1.0}
		   end
		end

		fun{ChordToSample Chord}
			case Chord of nil then nil
			[] H|T then {NoteToSample H}|{ChordToSample T}
			else nil
			end
		end

		fun{ToOneChord Chord}%Prend un accord sous forme de liste de NoteSampled et renvoie une seule liste avec les Notes additionne
		   case Chord of nil then nil
		   [] H|nil then H
		   [] H1|H2|T then {ToOneChord {Sum H1 H2}|T}
		   end
		end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				fun{WaveToSample Wave} 
					{Project.load Wave.1} %ou alors {Project.readFile Wave.1}
				end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				fun{Clip Bas Haut Item}
					case Item of H|T then if H<Bas then Bas|{Clip Bas Haut T}
							      else if H>Haut then Haut|{Clip Bas Haut T}
								   else H|{Clip Bas Haut T}
								   end
							      end
					else nil 
					end
				end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
	   fun {Loop D Music}
	local 
		fun {Repet M Acc}
			if Acc<D*44100.0 then 
				case M of nil then {Repet Music Acc}
				[]H|T then H|{Repet T Acc+1.0}
				end
			else
				nil
			end
		end
	in
		{Repet Music 0.0}
	end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
