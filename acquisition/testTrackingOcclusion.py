import viz
import viztask
import steamvr
import datetime
import scipy.io as scio
import utils


nSecWait 			= 6 	# number of seconds to wait after track loss before data can be recorded. Must pull trigger to actually record data
trackRate 			= 90 	# track rate of the device (Vive) that you are capturing from
qHaveSimultaneous	= True 	# use setup with Vive and simultaneous PPT and Intersense (True), or not (False)?
if 0:
	nTrial = 20
	nSec = 5		# number of seconds of data to capture for each trial
else:
	nTrial = 1
	nSec = 60		# number of seconds of data to capture for each trial
	
# define expected optical heading position here, so we can check if markers go way off (if wanted)
qCheckOptHeading = False
optHeadingPos = [-0.9793, 1.5508, 3.2704] 
optHeadLims   = [.5, .5, .5]


setup = utils.init(qHaveSimultaneous)

def TrackTask():
	prevPos = None
	allData = []
	tRegained = 0
	stage = 0 		# 0: wait for track loss, 1: wait for track regained, 2: wait for trigger pull, 3: trigger pulled. check optical heading position ok, 4: trigger released, ready for next trigger pull that will start actual data collection
	t = 0.
	opticalHeadScrewed = False
	tCount = -1
	while True:
		# wait for track regained
		stage = 0
		while True:
			pos = setup.trackerDataFun()
			if prevPos is not None and pos['vive']==prevPos['vive']:
				# position didn't change at all, not tracking
				if stage is not 1:
					setup.sounds.trialStart.play()
					print 'track lost'
					stage = 1
			else:
				# get here only once vive position/orientation starts changing again
				if stage==1:
					setup.sounds.trialCompleted.play()
					print 'track regained'
					tRegained = t
					stage = 2 if qCheckOptHeading else 4	# if not qCheckOptHeading, skip the check
				
				if stage==2 and t-tRegained > nSecWait and (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
					# first press, check if optical heading position is ok
					stage = 3
				
				if stage==3 and not (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
					# button/trigger released
					stage = 4 
				
				if stage==4 and (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
					# second press: time to record some data
					tCount += 1
					break
			prevPos = pos
			
			# check position of optical heading markers is within expected range. Otherwise markers probably switched
			if qCheckOptHeading and stage in [3,4] and any([abs(p-m)>l for p,m,l in zip(pos['optical_heading'][:3],optHeadingPos,optHeadLims)]):
				# optical markers screwed, notify
				if not opticalHeadScrewed:
					print 'optical heading error. current pose: ' + str(pos['optical_heading'])
					setup.sounds.alarm.play()
					opticalHeadScrewed = True
			else:
				opticalHeadScrewed = False
			
			# limit to update rate
			d = yield viztask.waitDraw()
			t = d.time
				

		# report position
		print 'capturing track data'
		setup.sounds.trialStart.play()
		count = 0
		data  = []
		while count < trackRate*nSec:
			ti = setup.trackerDataFun()
			ti['timeStamp'] = d.time
			data.append(ti)
			count += 1
			
			d = yield viztask.waitDraw()
		
		# store for later
		allData.append(data)
		setup.sounds.trialCompleted.play()
		
		# make filename
		if tCount+1==nTrial:
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
					
			# done
			viz.quit()


viztask.schedule(TrackTask())
