YUV		= ffmpeg
YUVFLAGS	= -f rawvideo -pix_fmt yuv420p -y
CLEAN		= rm -rf

BASICDIRS	= graph log motion out recon
DIRS		:= $(patsubst %,%.fast,${BASICDIRS}) \
DIRS		+= $(patsubst %,%.fastconstrained,${BASICDIRS})
DIRS		+= $(patsubst %,%.full,${BASICDIRS})
DIRS		+= $(patsubst %,%.fullconstrained,${BASICDIRS})
DIRS		+= in

ENCODER		= H264AVCEncoderLibTestStatic
FULLCFG		= encoder.full.cfg
FULLLOG		= log.full
FULLCONCFG	= encoder.fullconstrained.cfg
FULLCONLOG	= log.fullconstrained
FASTCFG		= encoder.fast.cfg
FASTLOG		= log.fast
FASTCONCFG	= encoder.fastconstrained.cfg
FASTCONLOG	= log.fastconstrained
TIME		= command time

IMGDIR		= ../frames
RANGE		= %03d
NVIEWS		= 2
VIEWORDER	= 0 1 

all: dirs yuvs fastconstrained fast fullconstrained full graphs

fast:
	@for view in ${VIEWORDER}; do \
		echo -e "\n########\n######## `date`" \
			| tee -a ${FASTLOG}/log_$${view}.txt \
			| tee -a ${FASTLOG}/err_$${view}.txt \
			>> ${FASTLOG}/time_$${view}.txt; \
		${TIME} -ao ${FASTLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FASTCFG} $${view} \
			>> ${FASTLOG}/log_$${view}.txt \
			2>> ${FASTLOG}/err_$${view}.txt; \
	done
fastconstrained:
	@for view in ${VIEWORDER}; do \
		echo -e "\n########\n######## `date`" \
			| tee -a ${FASTCONLOG}/log_$${view}.txt \
			| tee -a ${FASTCONLOG}/err_$${view}.txt \
			>> ${FASTCONLOG}/time_$${view}.txt; \
		${TIME} -ao ${FASTCONLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FASTCONCFG} $${view} \
			>> ${FASTCONLOG}/log_$${view}.txt \
			2>> ${FASTCONLOG}/err_$${view}.txt; \
	done
full:
	@for view in ${VIEWORDER}; do \
		echo -e "\n########\n######## `date`" \
			| tee -a ${FULLLOG}/log_$${view}.txt \
			| tee -a ${FULLLOG}/err_$${view}.txt \
			>> ${FULLLOG}/time_$${view}.txt; \
		${TIME} -ao ${FULLLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FULLCFG} $${view} \
			>> ${FULLLOG}/log_$${view}.txt \
			2>> ${FULLLOG}/err_$${view}.txt; \
	done
fullconstrained:
	@for view in ${VIEWORDER}; do \
		echo -e "\n########\n######## `date`" \
			| tee -a ${FULLCONLOG}/log_$${view}.txt \
			| tee -a ${FULLCONLOG}/err_$${view}.txt \
			>> ${FULLCONLOG}/time_$${view}.txt; \
		${TIME} -ao ${FULLCONLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FULLCONCFG} $${view} \
			>> ${FULLCONLOG}/log_$${view}.txt \
			2>> ${FULLCONLOG}/err_$${view}.txt; \
	done

dirs:
	@-for dir in ${DIRS}; do \
		mkdir $$dir 2>/dev/null; \
	done

graphs:
	@for mot in motion*/*.mot; do \
		if [ "plot*.sh" ]; then \
			for plot in plot*.sh; do \
				./$$plot $$mot; \
			done; \
		fi; \
	done
	@for log in log*/log*.txt; do \
		if [ "chart*.sh" ]; then \
			for chart in chart*.sh; do \
				./$$chart $$log; \
			done; \
		fi; \
	done

yuvs:
	@for i in ${VIEWORDER}; do \
		${YUV} -i ${IMGDIR}/$$((i+1)).${RANGE}.png ${YUVFLAGS} in/in_$${i}.yuv; \
	done

clean: clean-graphs
clean-all: clean clean-output clean-input
mrproper: clean-all clean-logs

clean-graphs:
	${CLEAN} graph*
clean-output:
	${CLEAN} out* recon* motion*
clean-input:
	${CLEAN} in
clean-logs:
	${CLEAN} log*

.PHONY: all unconstrained constrained graphs yuvs clean clean-all mrproper clean-graphs clean-input clean-output clean-logs
