import viz
import vizconnect
import steamvr

from collections import namedtuple

def init(qHaveSimultaneous):
	if qHaveSimultaneous:
		vizconnect.go('vizconnectSetups/vive_ppt_intersense.py')
	else:
		vizconnect.go('vizconnectSetups/viveLighthouse.py')
	piazza = viz.add('piazza.osgb')
	piazza2 = viz.add('piazza_animations.osgb')

	vive   = vizconnect.getRawTracker('head_tracker')
	if qHaveSimultaneous:
		optHead= vizconnect.getRawTracker('optical_heading')
		PPT1   = vizconnect.getRawTracker('ppt_1')
		PPT2   = vizconnect.getRawTracker('ppt_2')
		PPT3   = vizconnect.getRawTracker('ppt_3')
		PPT4   = vizconnect.getRawTracker('ppt_4')
		inertiacube = vizconnect.getRawTracker('inertiacube')

	# check controller is on
	steamvr.getControllerList()[0].isButtonDown(2)

	def getTrackInfo():
		if 1:
			if qHaveSimultaneous:
				return {'vive':vive.getPosition()+vive.getEuler(), 'optical_heading':optHead.getPosition()+optHead.getEuler(),'PPT1':PPT1.getPosition(),'PPT2':PPT2.getPosition(),'PPT3':PPT3.getPosition(),'PPT4':PPT4.getPosition(),'inertiacube':inertiacube.getEuler()}
			else:
				return {'vive':vive.getPosition()+vive.getEuler()}
		else:
			return {'viveController':steamvr.getControllerList()[0].getPosition()+steamvr.getControllerList()[0].getEuler()}
			
	trialStartSound			= viz.addAudio('sounds/quack.wav',play=0,volume=2.)
	trialCompletedSound 	= viz.addAudio('sounds/pop.wav',play=0,volume=2.)
	alarmSound 				= viz.addAudio('alarm.wav',play=0,volume=2.)
	
	# make return values
	Sounds		= namedtuple('Sounds', 'trialStart trialCompleted alarm')
	InitReturn	= namedtuple('initReturn', 'visuals sounds trackerDataFun')
	return InitReturn(visuals=[piazza,piazza2],sounds=Sounds(trialStart=trialStartSound,trialCompleted=trialCompletedSound,alarm=alarmSound),trackerDataFun=getTrackInfo)