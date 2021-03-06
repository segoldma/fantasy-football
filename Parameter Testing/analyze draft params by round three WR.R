rm(list=ls())

year<-2018
scoring<-"CUSTOM"
error.breaks<-c(-50, 25, 75, 125, 225, 400)
source("all data, optimize by round.R")


numDrafts<-250
numSims<-100
slot<-"Slot4"
file<-paste0("Parameter Testing/" ,scoring," analyze draft params by round 3WR ", year ,".RData")


#default parameters
# drafts<-lapply(1:numDrafts,function(x)simDraft(scoring=scoring))  #get picks going round by round,players taken probabilistically based on adp
# drafts[[2]]
# table(unlist(lapply(drafts, function(x) x$Player[6])))
# hist(sapply(drafts, function(x) sum(x$HALF)))
# 
# simScores<-lapply(drafts, function(x)replicate(numSims, simSeason(x, scoring=scoring)))
# save(simScores, file="simScores by round 1.RData")

#plot stabilization~numdrafts and numSims..sims stabilize very fast--large number of sims not needed--drafts stabilize slower,keep large numDrafts
# bydraft<-cummean(unlist(simScores))
# bysim<-cummean(unlist(lapply(1:numSims, function(x) lapply(simScores, `[[`, x))))
# plot(bydraft ,type="l", ylim=c(2030, 2080)) #cummean~draft
# lines(bysim, col="red", lty=2) #cummean~
# length(bysim)
# 
# bysim[20000]
# 
# quantile(unlist(simScores[sapply(drafts, function(x) sum(x$Player[1:4]=="Demaryius Thomas")==1)]))
# median(sapply(drafts[sapply(drafts, function(x) "QB"%in% x$Pos[1:6])], function(x) sum(x$HALF)))
# table(sapply(drafts2, function(x) sum(x$Pos[1:8]=="QB")))
# hist(unlist(simScores))
# quantile(unlist(simScores3))

cl<-makeCluster(2, type = "SOCK")
registerDoSNOW(cl)

#shift=0
drafts<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numWR=6)) 
simScores<-foreach(x=drafts, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores))

#shift=.25
drafts2<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring, numWR=5, numRB=6 ,outPos=rep("RB", 1), onePos=rep("QB", 10))) 
simScores2<-foreach(x=drafts2, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores2))

#shift=0
drafts3<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,numWR=5, numRB=6,outPos=rep("RB", 1) )) 
simScores3<-foreach(x=drafts3, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores3))

#shift=0, WR in R1
drafts4<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numWR=4, numRB=7,outPos = c(rep("RB", 1)))) #draft 1 qb in midrounds
simScores4<-foreach(x=drafts4, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores4))

#shift=0, zeroRB in R1-4sim
drafts5<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numWR=6,outPos = c(rep("WR", 1))))  #draft 1 qb in midrounds
simScores5<-foreach(x=drafts5, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores5))

#alpha=85, <=1 QB in R1-11
drafts6<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numWR=6, onePos = rep("QB", 10) ,outPos=rep("WR",1))) #waiting on QB and DEF
simScores6<-foreach(x=drafts6, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores6))

#shift=0, heavyWR
drafts7<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numRB=4, numWR=7, numTE=1, numQB=2,numK=1, numFLEX=0, numDST=1))
simScores7<-foreach(x=drafts7, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores7))

#shift=0, heavyRB, <=1 QB in r1-11
drafts8<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numRB=6, numWR=5, numTE=1, numQB=2,numK=1, numFLEX=0, numDST=1)) 
simScores8<-foreach(x=drafts8, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
quantile(unlist(simScores8))

#shift=0, no QB backup
drafts9<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0, numRB=5, numWR=6, numTE=2, numQB=1,numK=1, numFLEX=0, numDST=1))
simScores9<-foreach(x=drafts9, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }

#shift=0, QB+TE backup, <=1 QB in R1-11
drafts10<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0,numRB=4, numWR=6, numTE=2, numQB=2, numK=1, numDST=1 )) #onePos = rep("QB", 10)
simScores10<-foreach(x=drafts10, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }

#zero WR
drafts11<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0,numRB=5, numWR=6, numTE=1, numQB=2, numK=1, numDST=1,
                                                 onePos = rep("QB", 10), outPos=rep("RB", 4) )) #onePos = rep("QB", 10)
simScores11<-foreach(x=drafts11, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }


drafts12<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0,numRB=6, numWR=5, numTE=1, numQB=2, numK=1, numDST=1,
                                                 onePos = rep("QB", 10), outPos=rep("TE", 2) )) #onePos = rep("QB", 10)
simScores12<-foreach(x=drafts12, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }


#experiment with draft-pick trade
vec<-getPickDF(numPicks=16)$Slot4
vec<-c(vec[-c(2:3)], getPickDF(numPicks=16)$Slot10[c(2, 3)] )%>% sort() 
vec<-vec[1:16]

trade1<-lapply(1:numDrafts,function(x)simDraft(slot=slot,scoring=scoring,shift=0,numRB=6, numWR=5, numTE=1, numQB=2, numK=1,
                                               numDST=1,customPicks = vec, onePos = rep("QB", 10)
                                               )) #
tradeScores1<-foreach(x=trade1, .packages = c("data.table", "dplyr", "plyr"))%dopar%{
  replicate(numSims, simSeason(x, scoring=scoring, numWR = 3)) }
trade1[[17]]
quantile(unlist(tradeScores1))
quantile(unlist(simScores2))
quantile(unlist(simScores3[sapply(drafts3, function(x) sum(x$Player[1:2]=="Jordan Howard")==1)]))
quantile(unlist(simScores5[sapply(drafts5, function(x) sum(x$Player[1:2]=="Christian Mccaffrey")==1)]))


quantile(unlist(simScores8))
freqs<-as.data.frame.matrix(table(unlist(lapply(drafts8, function(x) x$Player)), unlist(lapply(trade1, function(x) 1:nrow(x)))))
freqs[ order(freqs[,1], freqs[, 2], freqs[,3], freqs[, 4], freqs[, 5], freqs[, 5], freqs[, 5], freqs[, 6], freqs[, 7], freqs[, 8], decreasing = T),]

drafts12[[14]]

hist(unlist(simScores))
table(unlist(lapply(drafts10, function(x) x$Player[3])))
quantile(unlist(simScores[sapply(drafts5, function(x) sum(x$Player[1:2]=="Lesean Mccoy")==1)]))


#loop through every draft slot--may take a while
drafts_allSlots<-lapply(paste("Slot", 1:12, sep=""), function(x)
  lapply(1:numDrafts,function(y) simDraft(scoring=scoring,shift=0,numRB=6, numWR=5, numTE=1, numQB=2, numK=1, numDST=1 , slot = x))
)
simScores_allSlots<-foreach(x=drafts_allSlots,.packages = c("data.table", "dplyr" ,"plyr"))%dopar%{
  lapply(x, function(y)replicate(numSims,simSeason(y, scoring=scoring, numWR=3)))}
#results
lapply(simScores_allSlots, function(x)quantile(unlist(x)))


#loop through every draft slot--may take a while
drafts_allSlots_zeroRB<-lapply(paste("Slot", 1:12, sep=""), function(x)
  lapply(1:numDrafts,function(y) simDraft(scoring=scoring,shift=0,numRB=6, numWR=5, numTE=1, numQB=2, numK=1, numDST=1 , slot = x, outPos=rep("RB", 1)))
)
simScores_allSlots_zeroRB<-foreach(x=drafts_allSlots_zeroRB,.packages = c("data.table", "dplyr" ,"plyr"))%dopar%{
  lapply(x, function(y)replicate(numSims,simSeason(y, scoring=scoring, numWR=3)))}


#loop through every draft slot--may take a while
drafts_allSlots_zeroWR<-lapply(paste("Slot", 1:12, sep=""), function(x)
  lapply(1:numDrafts,function(y) simDraft(scoring=scoring,shift=0,numRB=6, numWR=5, numTE=1, numQB=2, numK=1, numDST=1 , slot = x, outPos=rep("WR", 1)))
)
simScores_allSlots_zeroWR<-foreach(x=drafts_allSlots_zeroWR,.packages = c("data.table", "dplyr" ,"plyr"))%dopar%{
  lapply(x, function(y)replicate(numSims,simSeason(y, scoring=scoring, numWR=3)))}

save(list=ls()[grepl("simScores|drafts",ls())], file=file)

pos<-4
bool<-drafts_allSlots[[pos]]
freqs<-as.data.frame.matrix(table(unlist(lapply(bool, function(x) x$Player)), unlist(lapply(bool, function(x) 1:nrow(x)))))
freqs[ order(freqs[,1], freqs[, 2], freqs[,3], freqs[, 4], freqs[, 5], freqs[, 5], freqs[, 5], freqs[, 6], freqs[, 7], freqs[, 8], decreasing = T),][1:50,]

freqs<-as.data.frame.matrix(table(unlist(lapply(bool, function(x) x$Player)), unlist(lapply(bool, function(x) 1:nrow(x)))))
freqs$Player<-row.names(freqs)
freqs$Pos<-adp$Pos[match(freqs$Player, adp$Player)]
row.names(freqs)<-NULL
mostCommon<-lapply(1:16, function(x) {ret<-freqs[order(freqs[, x], decreasing = T),c(x, "Player", "Pos") ][1:4,];colnames(ret)[1]<-"Times";ret$Round<-x;ret})
mostCommon<-ldply(mostCommon, data.frame)
mostCommon[,c("Player", "Pos", "Round", "Times")]


#####PLOT#####

load(paste0("Parameter Testing/" ,scoring," analyze draft params by round 3WR 2017.RData"))

Parameters<-c("1. RBx5,WRx6,QBx2,K/DST/TEx1 (default)", "2. zero RB in R1, 6 RBs,  \u2264 1 QB in 1-11","3. zero RB in R1, 6 RBs, shift=0",
              "4. zero RB in R1, 7RBs, shift=0", "5. zero WR in R1, shift=0",  "6. zeroWR in R1, \u2264 1QB in R1-11, shift=0", 
              "7. RBx4, WRx7, shift=0", "8. RBx6, WRx5, shift=0",
              "9. RBx5,WRx6,TEx2,QB/DST/Kx1, shift=0", "10. RBx4,WRx6,QB/TEx2,DST/Kx1, shift=0", 
              "11. Zero RB in R1-4, \u2264 1QB in R1-11,  shift=0", "12. Case 8 + Zero TE in R1-2" )
makeParamPlot(Parameters=Parameters, Title=paste0("Simulation Results for Different Draft Parameters - 3WR League, ", scoring, " Scoring"))

ggsave(paste0("Parameter Testing/" , scoring, " scoring-by round parameters.jpeg"),width = 7, height=3.4 , units = "in")




freqs<-as.data.frame.matrix(table(unlist(lapply(drafts10, function(x) x$Player)), unlist(lapply(drafts10, function(x) 1:nrow(x)))))
freqs$Player<-row.names(freqs)
freqs$Pos<-adp$Pos[match(freqs$Player, adp$Player)]
row.names(freqs)<-NULL
mostCommon<-lapply(1:15, function(x) freqs[order(freqs[, x], decreasing = T),c(x, "Player", "Pos") ][1:3,])


#####PLOT#####

load(paste0("Parameter Testing/" ,scoring," analyze draft params by round 3WR 2017.RData"))
makeSlotPlot(Title = paste0("Results by Draft Slot,  3WR League, ", scoring, " Scoring"))
ggsave(paste0("Parameter Testing/" ,scoring, " scoring-by round slots.jpeg"),width = 7, height=3.4 , units = "in")

