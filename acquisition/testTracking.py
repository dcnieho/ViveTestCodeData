import viz
import viztask
import steamvr
import datetime
import scipy.io as scio
import utils


nSec 				= 6 	# number of seconds of data to capture for each trial
trackRate 			= 90 	# track rate of the device (Vive) that you are capturing from
nTrial 				= None 	# if you have a known number of trials for which you want to measure, specify that here
qHaveSimultaneous	= True 	# use setup with Vive and simultaneous PPT and Intersense (True), or not (False)?

# setup screen and tracker, etc
setup = utils.init(qHaveSimultaneous)

def TrackTask():
	prevPos = None
	tracking= False
	allData = []
	tCount = -1
	# run until number of trials finished, or forever
	while True:
		# wait for trigger press
		while not (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
			pos = setup.trackerDataFun()
			if prevPos is not None and pos['vive']==prevPos['vive']:
				# position didn't change at all, not tracking
				if tracking:
					print 'track lost'
					setup.sounds.trialStart.play()
				tracking = False
			else:
				if not tracking:
					print 'track regained'
				tracking = True
			prevPos = pos
			
			# store data upon keypress, or upon requested number of trials reached
			if (viz.key.isDown(viz.KEY_CONTROL_L, immediate=True) and viz.key.isDown('s', immediate=True) and len(allData)>0) or (nTrial is not None and tCount==nTrial):
				# make filename
				time = datetime.datetime.now()
				fname = ''.join((str(time.year) +
								str(time.month).zfill(2) +
								str(time.day).zfill(2) +
								str(time.hour).zfill(2) +
								str(time.minute).zfill(2) +
								str(time.second).zfill(2)))
				
				saveData = {}
				saveData['data'] = allData
				scio.savemat('data/'+fname,saveData,long_field_names=True,do_compression=True,oned_as='column')
				
				# done, either quit or notify and clear data store
				if nTrial is not None:
					viz.quit()
				else:
					setup.sounds.trialStart.play()
					allData = []
			
			# limit to update rate
			d=yield viztask.waitDraw()
				

		# report position
		print 'capturing track data'
		tCount += 1
		count = 0
		data  = []
		while count < trackRate*nSec:
			ti = setup.trackerDataFun()
			ti['timeStamp'] = d.time
			data.append(ti)
			count += 1
			
			d=yield viztask.waitDraw()
		
		# store for later
		allData.append(data)
		setup.sounds.trialCompleted.play()
		
		# Wait for trigger to release if still down
		if steamvr.getControllerList()[0].isButtonDown(2):
			yield viztask.waitSensorUp(steamvr.getControllerList()[0], steamvr.BUTTON_TRIGGER)


viztask.schedule(TrackTask())