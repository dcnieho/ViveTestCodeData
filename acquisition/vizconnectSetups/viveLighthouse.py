"""
This module was generated by Vizconnect.
Version: 1.04
Generated on: 2015-11-13 04:20:15.814000
"""

import viz
import vizconnect

#################################
# Parent configuration, if any
#################################

def getParentConfiguration():
	#VC: set the parent configuration
	_parent = ''
	
	#VC: return the parent configuration
	return _parent


#################################
# Pre viz.go() Code
#################################

def preVizGo():
	return True


#################################
# Pre-initialization Code
#################################

def preInit():
	"""Add any code here which should be called after viz.go but before any initializations happen.
	Returned values can be obtained by calling getPreInitResult for this file's vizconnect.Configuration instance."""
	return None


#################################
# Group Code
#################################

def initGroups(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawGroup = vizconnect.getRawGroupDict()
	
	#VC: return values can be modified here
	return None


#################################
# Display Code
#################################

def initDisplays(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawDisplay = vizconnect.getRawDisplayDict()

	#VC: initialize a new display
	_name = 'main_display'
	if vizconnect.isPendingInit('display', _name, initFlag, initList):
		#VC: init the raw object
		if initFlag&vizconnect.INIT_RAW:
			#VC: set the window for the display
			_window = viz.MainWindow
			
			#VC: set some parameters
			index = 0
			
			#VC: create the raw object
			import steamvr
			# Get sensor from extension if not specified
			hmd = None
			sensor = None
			hmdList = steamvr.getExtension().getHMDList()
			if hmdList:
				try:
					sensor = hmdList[index]
				except IndexError:
					viz.logError("** ERROR: Not enough HMD's")
			else:
				viz.logError('** ERROR: Failed to detect SteamVR HMD')
			if sensor:
				hmd = steamvr.HMD(sensor=sensor, window=_window)
			_window.displayNode = hmd
			rawDisplay[_name] = _window
	
		#VC: init the wrapper (DO NOT EDIT)
		if initFlag&vizconnect.INIT_WRAPPERS:
			vizconnect.addDisplay(rawDisplay[_name], _name, make='Valve', model='SteamVR HMD')
	
		#VC: set the parent of the node
		if initFlag&vizconnect.INIT_PARENTS:
			vizconnect.getDisplay(_name).setParent(vizconnect.getAvatar('main_avatar').getAttachmentPoint('head'))

	#VC: set the name of the default
	vizconnect.setDefault('display', 'main_display')

	#VC: return values can be modified here
	return None


#################################
# Tracker Code
#################################

def initTrackers(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawTracker = vizconnect.getRawTrackerDict()

	#VC: initialize a new tracker
	_name = 'head_tracker'
	if vizconnect.isPendingInit('tracker', _name, initFlag, initList):
		#VC: init the raw object
		if initFlag&vizconnect.INIT_RAW:
			#VC: set some parameters
			index = 0
			
			#VC: create the raw object
			import steamvr
			try:
				tracker = steamvr.getExtension().getHMDList()[index]
			except IndexError:
				viz.logWarn("** WARNING: Not able to connect to tracker at index {0}. It's likely that not enough trackers are connected.".format(index))
				tracker = viz.addGroup()
				tracker.invalidTracker = True
			rawTracker[_name] = tracker
	
		#VC: init the wrapper (DO NOT EDIT)
		if initFlag&vizconnect.INIT_WRAPPERS:
			vizconnect.addTracker(rawTracker[_name], _name, make='Valve', model='SteamVR HMD Tracker')

	#VC: set the name of the default
	vizconnect.setDefault('tracker', 'head_tracker')

	#VC: return values can be modified here
	return None


#################################
# Input Code
#################################

def initInputs(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawInput = vizconnect.getRawInputDict()

	#VC: initialize a new input
	_name = 'keyboard'
	if vizconnect.isPendingInit('input', _name, initFlag, initList):
		#VC: init the raw object
		if initFlag&vizconnect.INIT_RAW:
			#VC: set some parameters
			index = 0
			
			#VC: create the raw object
			d = viz.add('directinput.dle')
			device = d.getKeyboardDevices()[index]
			rawInput[_name] = d.addKeyboard(device)
	
		#VC: init the wrapper (DO NOT EDIT)
		if initFlag&vizconnect.INIT_WRAPPERS:
			vizconnect.addInput(rawInput[_name], _name, make='Generic', model='Keyboard')

	#VC: return values can be modified here
	return None


#################################
# Event Code
#################################

def initEvents(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawEvent = vizconnect.getRawEventDict()

	#VC: return values can be modified here
	return None


#################################
# Transport Code
#################################

def initTransports(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawTransport = vizconnect.getRawTransportDict()

	#VC: initialize a new transport
	_name = 'main_transport'
	if vizconnect.isPendingInit('transport', _name, initFlag, initList):
		#VC: request that any dependencies be created
		if initFlag&vizconnect.INIT_INDEPENDENT:
			initTrackers(vizconnect.INIT_INDEPENDENT, ['head_tracker'])
	
		#VC: init the raw object
		if initFlag&vizconnect.INIT_RAW:
			#VC: set some parameters
			orientationTracker = vizconnect.getTracker('head_tracker').getNode3d()
			debug = False
			acceleration = 2
			maxSpeed = 2
			rotationAcceleration = 60
			maxRotationSpeed = 65
			autoBreakingDragCoef = 0.1
			dragCoef = 0.0001
			rotationAutoBreakingDragCoef = 0.2
			rotationDragCoef = 0.0001
			usingPhysics = False
			parentedTracker = False
			transportationGroup = None
			
			#VC: create the raw object
			from transportation import wand_magic_carpet
			rawTransport[_name] = wand_magic_carpet.WandMagicCarpet(	orientationTracker=orientationTracker,
																					debug=debug,
																					acceleration=acceleration,
																					maxSpeed=maxSpeed,
																					rotationAcceleration=rotationAcceleration,
																					maxRotationSpeed=maxRotationSpeed,
																					autoBreakingDragCoef=autoBreakingDragCoef,
																					dragCoef=dragCoef,
																					rotationAutoBreakingDragCoef=rotationAutoBreakingDragCoef,
																					rotationDragCoef=rotationDragCoef,
																					usingPhysics=usingPhysics,
																					parentedTracker=parentedTracker,
																					node=transportationGroup)
	
		#VC: init the wrapper (DO NOT EDIT)
		if initFlag&vizconnect.INIT_WRAPPERS:
			vizconnect.addTransport(rawTransport[_name], _name, make='Virtual', model='WandMagicCarpet')
	
		#VC: set the pivot of the node
		if initFlag&vizconnect.INIT_PIVOTS:
			vizconnect.getTransport(_name).setPivot(vizconnect.getAvatar('main_avatar').getAttachmentPoint('head').getNode3d())

	#VC: set the name of the default
	vizconnect.setDefault('transport', 'main_transport')

	#VC: return values can be modified here
	return None


#################################
# Tool Code
#################################

def initTools(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawTool = vizconnect.getRawToolDict()

	#VC: return values can be modified here
	return None


#################################
# Avatar Code
#################################

def initAvatars(initFlag=vizconnect.INIT_INDEPENDENT, initList=None):
	#VC: place any general initialization code here
	rawAvatar = vizconnect.getRawAvatarDict()

	#VC: initialize a new avatar
	_name = 'main_avatar'
	if vizconnect.isPendingInit('avatar', _name, initFlag, initList):
		#VC: init the raw object
		if initFlag&vizconnect.INIT_RAW:
			#VC: set some parameters
			head = False
			rightHand = False
			leftHand = False
			torso = False
			lowerBody = False
			rightArm = False
			leftArm = False
			
			#VC: create the raw object
			# base avatar
			import vizfx
			avatar = vizfx.addChild('mark.cfg')
			avatar._bodyPartDict = {}
			avatar._handModelDict = {}
			avatar.visible(head, r'mark_head.cmf')
			avatar.visible(rightHand, r'mark_hand_r.cmf')
			avatar.visible(leftHand, r'mark_hand_l.cmf')
			avatar.visible(torso, r'mark_torso.cmf')
			avatar.visible(lowerBody, r'mark_legs.cmf')
			avatar.visible(rightArm, r'mark_arm_r.cmf')
			avatar.visible(leftArm, r'mark_arm_l.cmf')
			rawAvatar[_name] = avatar
	
		#VC: init the wrapper (DO NOT EDIT)
		if initFlag&vizconnect.INIT_WRAPPERS:
			vizconnect.addAvatar(rawAvatar[_name], _name, make='WorldViz', model='Mark')
	
		#VC: init the animator
		if initFlag&vizconnect.INIT_ANIMATOR:
			# need to get the raw tracker dict for animating the avatars
			from vizconnect.util.avatar import animator
			from vizconnect.util.avatar import skeleton
			
			# get the skeleton from the avatar
			_skeleton = skeleton.CompleteCharactersHD(rawAvatar[_name])
			
			#VC: set which trackers animate which body part
			# format is: bone: (tracker, parent, degrees of freedom used)
			_trackerAssignmentDict = {
				vizconnect.AVATAR_HEAD:(vizconnect.getTracker('head_tracker').getNode3d(), None, vizconnect.DOF_6DOF),
			}
			
			#VC: create the raw object
			_rawAnimator = animator.Direct(rawAvatar[_name], _skeleton, _trackerAssignmentDict)
			
			#VC: set animator in wrapper (DO NOT EDIT)
			vizconnect.getAvatar(_name).setAnimator(_rawAnimator, make='Virtual', model='Direct')
	
		#VC: set the parent of the node
		if initFlag&vizconnect.INIT_PARENTS:
			vizconnect.getAvatar(_name).setParent(vizconnect.getTransport('main_transport'))

	#VC: set the name of the default
	vizconnect.setDefault('avatar', 'main_avatar')

	#VC: return values can be modified here
	return None


#################################
# Application Settings
#################################

def initSettings():
	#VC: apply general application settings
	viz.mouse.setTrap(False)
	viz.mouse.setVisible(viz.MOUSE_AUTO_HIDE)
	vizconnect.setMouseTrapToggleKey('')
	
	#VC: return values can be modified here
	return None


#################################
# Post-initialization Code
#################################

def postInit():
	"""Add any code here which should be called after all of the initialization of this configuration is complete.
	Returned values can be obtained by calling getPostInitResult for this file's vizconnect.Configuration instance."""
	return None


#################################
# Stand alone configuration
#################################

def initInterface():
	#VC: start the interface
	vizconnect.interface.go(__file__,
							live=True,
							openBrowserWindow=True,
							startingInterface=vizconnect.interface.INTERFACE_STARTUP)

	#VC: return values can be modified here
	return None


###############################################

if __name__ == "__main__":
	initInterface()
	viz.add('piazza.osgb')
	viz.add('piazza_animations.osgb')

