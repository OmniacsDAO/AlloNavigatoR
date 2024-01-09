## Load Libraries
library(bslib)
library(bsicons)
library(shinyjs)
library(shinyWidgets)
library(readr)
library(lubridate)
options(scipen=999)

########################################################################
## Load All data and Functions
########################################################################
arbProjects <- read_csv("data/arbProjectsDF.csv",show_col_types = FALSE)
arbVotesDF <- read_csv("data/arbVotesDF.csv",show_col_types = FALSE)
arbRoundsDF <- read_csv("data/arbRoundsDF.csv",show_col_types = FALSE)
########################################################################
########################################################################


########################################################################
## Helper Functions
########################################################################
trim_add <- function(x) paste0(substr(x,1,10),".....",substr(x,nchar(x)-9,nchar(x)))
mc_add <- function(x)
{
	x <- sort(x)
	names(x) <- sapply(x,trim_add)
	return(x)
}

parse_grant <- function(x) paste0(paste("<strong>",gsub("project","Project ",names(x)),"</strong>","<br/>",x),collapse="<br/><br/>")
parse_grant2 <- function(x) paste0(paste("<strong>",gsub("round","Round ",names(x)),"</strong>","<br/>",x),collapse="<br/><br/>")

projc_roundsO <- function(x,arbVotesDF,arbProjects)
{
	projectsDFT <- arbProjects[arbProjects$projectId==x,]
	votesDFT <- arbVotesDF[arbVotesDF$projectId==x,]
	projectsDFT$projectId <- sapply(projectsDFT$projectId,trim_add)
	cmatcheshtml <- apply(projectsDFT[,c(3,11:12,10,13,16:17)],1,parse_grant)
	card(
			card_header(class = "bg-dark",paste0(
								"$",
								round(sum(votesDFT$amountUSD),2)
								),br(),
								paste0(
								length(unique(votesDFT$voter)),
								" Donors & ",
								length((votesDFT$amountUSD)),
								" Donations"
			)),
			max_height = 300,full_screen = TRUE,
			markdown(cmatcheshtml)
		)
}

projc_rounds <- function(x,y,arbVotesDF,arbProjects)
{
	projectsDFT <- arbProjects[arbProjects$projectId==x,]
	votesDFT <- arbVotesDF[arbVotesDF$projectId==x & arbVotesDF$roundId==y,]
	cmatcheshtml <- apply(projectsDFT[,c(11:12,10,13,16:17)],1,parse_grant)
	card(
			card_header(class = "bg-dark",paste0(
								"$",
								round(sum(votesDFT$amountUSD),2),
								" (",
								length(unique(votesDFT$voter)),
								" Donors & ",
								length((votesDFT$amountUSD)),
								" Donations)"
			)),
			max_height = 200,full_screen = TRUE,
			markdown(cmatcheshtml),
		)
}

projc_voters <- function(x,y,arbVotesDF,arbProjects)
{
	projectsDFT <- arbProjects[arbProjects$projectId==x,]
	votesDFT <- arbVotesDF[arbVotesDF$projectId==x & arbVotesDF$voter==y,]
	cmatcheshtml <- apply(projectsDFT[,c(11:12,10,13,16:17)],1,parse_grant)
	card(
			card_header(class = "bg-dark",paste0(
								"$",
								round(sum(votesDFT$amountUSD),2),
								" (",
								length(votesDFT$amountUSD),
								" Donations)"
			)),
			max_height = 200,full_screen = TRUE,
			markdown(cmatcheshtml)
		)
}

roundc_proj <- function(x,y,arbVotesDF,arbRoundsDF)
{
	arbRoundsDFT <- arbRoundsDF[arbRoundsDF$roundId==x,]
	votesDFT <- arbVotesDF[arbVotesDF$roundId==x & arbVotesDF$projectId==y,]
	cmatcheshtml <- apply(arbRoundsDFT[,c(3:4,17:18,5:6)],1,parse_grant2)
	card(
			card_header(class = "bg-dark",paste0(
								"$",
								round(sum(votesDFT$amountUSD),2),
								" (",
								length(unique(votesDFT$voter)),
								" Donors & ",
								length(votesDFT$amountUSD),
								" Donations)"
			)),
			max_height = 400,full_screen = TRUE,
			markdown(cmatcheshtml)
		)
}

roundc_projO <- function(x,arbVotesDF,arbRoundsDF)
{
	arbRoundsDFT <- arbRoundsDF[arbRoundsDF$roundId==x,]
	votesDFT <- arbVotesDF[arbVotesDF$roundId==x,]
	cmatcheshtml <- apply(arbRoundsDFT[,c(3:4,17:18,5:6)],1,parse_grant2)
	card(
			card_header(class = "bg-dark",paste0(
								"$",
								round(sum(votesDFT$amountUSD),2)
								),br(),
								paste0(
								length(unique(votesDFT$voter)),
								" Donors & ",
								length(votesDFT$amountUSD),
								" Donations"
			)),
			max_height = 300,full_screen = TRUE,
			markdown(cmatcheshtml)
		)
}

donorc_over <- function(x,arbVotesDF)
{
	votesDFT <- arbVotesDF[arbVotesDF$voter==x,]
	markdown(paste0(
			"* `",
			trim_add(x),
			"` ($",
			round(sum(votesDFT$amountUSD)),
			" in ",
			length(votesDFT$amountUSD),
			" Txs)"
	))
}

########################################################################
########################################################################


########################################################################
## Server Code
########################################################################
function(input, output, session) {


	########################################################################
	## Overview Tab
	########################################################################
	output$tabOV <- renderUI({
								tprojst1 <- arbVotesDF
								tprojst2 <- names(sort(tapply(tprojst1$amountUSD,tprojst1$voter,sum),decreasing=TRUE))
								tprojs <- tprojst2[1:min(length(tprojst2),5)]
								layout_column_wrap(
													value_box(
																title = "Donations",
																value=paste0("$",round(sum(arbVotesDF$amountUSD),2)),
																showcase = bs_icon("cash-coin"),
																theme = "light",
																p(paste0(
																	length(unique(arbVotesDF$voter)),
																	" Donors"
																)),
																p(paste0(
																	length(arbVotesDF$amountUSD),
																	" Donations"
																)),
																p(paste0(
																	"$",
																	round(max(arbVotesDF$amountUSD),2),
																	" Max Donation"
																))
													),
													value_box(
																title = "Top Donors",
																value=NULL,
																showcase = bs_icon("people"),
																theme = "light",
																donorc_over(tprojs[1],arbVotesDF),
																donorc_over(tprojs[2],arbVotesDF),
																donorc_over(tprojs[3],arbVotesDF),
																donorc_over(tprojs[4],arbVotesDF),
																donorc_over(tprojs[5],arbVotesDF),
													)
								)
					})
	output$tabOP <- renderUI({
								tprojst1 <- arbVotesDF
								tprojst2 <- names(sort(tapply(tprojst1$amountUSD,tprojst1$projectId,sum),decreasing=TRUE))
								tprojs <- tprojst2[1:min(length(tprojst2),12)]
								tprojst2r <- names(sort(tapply(tprojst1$amountUSD,tprojst1$roundId,sum),decreasing=TRUE))
								tprojsr <- tprojst2r[1:min(length(tprojst2r),12)]
								layout_column_wrap(
									card(
											fluidRow(column(12,h5("Top Funded Projects (Max 12)"),align="center")),
											layout_column_wrap(
																width = 1/2,
																!!!lapply(tprojs, projc_roundsO,arbVotesDF=arbVotesDF,arbProjects=arbProjects)
											)
									),
									card(
											fluidRow(column(12,h5("Top Funded Rounds (Max 12)"),align="center")),
											layout_column_wrap(
																width = 1/2,
																!!!lapply(tprojsr, roundc_projO,arbVotesDF=arbVotesDF,arbRoundsDF=arbRoundsDF)
											)
									),
								)

					})
	########################################################################
	########################################################################


	
	########################################################################
	## Rounds Tab
	########################################################################
	output$roundsd <- 	renderUI({list(hr(),selectInput("sel_round",label="Select Round",choices=mc_add(unique(arbProjects$roundId)),selected=mc_add(unique(arbProjects$roundId))[2]))})

	output$tabRV <- renderUI({
								layout_column_wrap(
													value_box(
																title = popover(
																					span(arbRoundsDF$roundName[match(input$sel_round,arbRoundsDF$roundId)],bs_icon("info-circle")),
																					title = arbRoundsDF$roundName[match(input$sel_round,arbRoundsDF$roundId)],
																					markdown(paste0(
																										h4("Eligibility Description"),
																										"\n",
																										arbRoundsDF$roundEligibilityDescription[match(input$sel_round,arbRoundsDF$roundId)],
																										hr(),
																										h4("Eligibility Requirements"),
																										"\n",
																										arbRoundsDF$roundEligibilityRquirements[match(input$sel_round,arbRoundsDF$roundId)]
																							)
																					)
																		),
																value= br(),
																showcase = bs_icon("info-square-fill"),
																theme = "light",
																p("Round Type :",toupper(arbRoundsDF$roundType[match(input$sel_round,arbRoundsDF$roundId)])),
																p("Start :",format(as_date(as_datetime(arbRoundsDF$roundStartTime[match(input$sel_round,arbRoundsDF$roundId)])),"%d %b %Y")),
																p("End :",format(as_date(as_datetime(arbRoundsDF$roundEndTime[match(input$sel_round,arbRoundsDF$roundId)])),"%d %b %Y")),
																
													),
													value_box(
																title = "Donations",
																value=paste0("$",round(sum(arbProjects$projectAmountUSD[arbProjects$roundId==input$sel_round]),2)),
																showcase = bs_icon("cash-coin"),
																theme = "light",
																p(paste0(
																	length(unique(arbVotesDF$voter[arbVotesDF$roundId==input$sel_round])),
																	" Donors"
																)),
																p(paste0(
																	length((arbVotesDF$amountUSD[arbVotesDF$roundId==input$sel_round])),
																	" Donations"
																)),
																p(paste0(
																	"$",
																	suppressWarnings(ifelse(
																			is.finite(round(max(arbVotesDF$amountUSD[arbVotesDF$roundId==input$sel_round]))),
																			round(max(arbVotesDF$amountUSD[arbVotesDF$roundId==input$sel_round]),2),
																			0
																	)),
																	" Max Donation"
																)),
																p(paste0(
																	"$",
																	suppressWarnings(ifelse(
																			is.finite(round(median(arbVotesDF$amountUSD[arbVotesDF$roundId==input$sel_round]))),
																			round(median(arbVotesDF$amountUSD[arbVotesDF$roundId==input$sel_round]),2),
																			0
																	)),
																	" Median Donation"
																))
													),
													value_box(
																title = "Projects in Round",
																value=length(arbProjects$projectId[arbProjects$roundId==input$sel_round]),
																showcase = bs_icon("back"),
																theme = "light",
																p(length(arbProjects$projectId[arbProjects$roundId==input$sel_round & arbProjects$projectStatus=="APPROVED"])," Accepted"),
																p(length(arbProjects$projectId[arbProjects$roundId==input$sel_round & arbProjects$projectStatus=="REJECTED"])," Rejected"),
																p(length(arbProjects$projectId[arbProjects$roundId==input$sel_round & arbProjects$projectStatus=="PENDING"])," Pending")
													)
								)
					})
	output$tabTP <- renderUI({
								tprojst1 <- arbVotesDF[arbVotesDF$roundId==input$sel_round,]
								tprojst2 <- names(sort(tapply(tprojst1$amountUSD,tprojst1$projectId,sum),decreasing=TRUE))
								if(length(tprojst2)==0) return(NULL)
								tprojs <- tprojst2[1:min(length(tprojst2),12)]
								list(
										br(),
										fluidRow(column(12,h5("Top Funded Projects in this Round (Max 12)"),align="center")),
										layout_column_wrap(
															width = 1/3,
															!!!lapply(tprojs, projc_rounds,y=input$sel_round,arbVotesDF=arbVotesDF,arbProjects=arbProjects)

										)

								)
					})
	########################################################################
	########################################################################


	########################################################################
	## Project Tab
	########################################################################
	output$projsd <- renderUI({list(hr(),selectInput("sel_proj",label="Select Project",choices=mc_add(unique(arbProjects$projectId)),selected=mc_add(unique(arbProjects$projectId))[182]))})
	
	output$tabPV <- renderUI({
								layout_column_wrap(
													value_box(
																title = "Donations",
																value=paste0("$",round(sum(arbVotesDF$amountUSD[arbVotesDF$projectId==input$sel_proj]),2)),
																showcase = bs_icon("cash-coin"),
																theme = "light",
																p(paste0(
																	length(unique(arbVotesDF$voter[arbVotesDF$projectId==input$sel_proj])),
																	" Donors"
																)),
																p(paste0(
																	length((arbVotesDF$amountUSD[arbVotesDF$projectId==input$sel_proj])),
																	" Donations"
																)),
																p(paste0(
																	"$",
																	suppressWarnings(ifelse(
																			is.finite(round(max(arbVotesDF$amountUSD[arbVotesDF$projectId==input$sel_proj]),2)),
																			round(max(arbVotesDF$amountUSD[arbVotesDF$projectId==input$sel_proj]),2),
																			0
																	)),
																	" Max Donation"
																))
													),
													value_box(
																title = "Rounds Applied",
																value=length(arbProjects$roundId[arbProjects$projectId==input$sel_proj]),
																showcase = bs_icon("back"),
																theme = "light",
																p(length(arbProjects$roundId[arbProjects$projectId==input$sel_proj & arbProjects$projectStatus=="APPROVED"])," Accepted"),
																p(length(arbProjects$roundId[arbProjects$projectId==input$sel_proj & arbProjects$projectStatus=="REJECTED"])," Rejected"),
																p(length(arbProjects$roundId[arbProjects$projectId==input$sel_proj & arbProjects$projectStatus=="PENDING"])," Pending")
													)
								)
					})
	output$tabPP <- renderUI({
								if(is.null(input$sel_proj)) return(NULL)
								tprojst1 <- arbVotesDF[arbVotesDF$projectId==input$sel_proj,]
								tprojst2 <- names(sort(tapply(tprojst1$amountUSD,tprojst1$roundId,sum),decreasing=TRUE))
								if(length(tprojst2)==0) return(NULL)
								tprojs <- tprojst2[1:min(length(tprojst2),12)]
								list(
										br(),
										fluidRow(column(12,h5("Top Rounds Participated In (Max 12)"),align="center")),
										layout_column_wrap(
															width = 1/3,
															!!!lapply(tprojs, roundc_proj,y=input$sel_proj,arbVotesDF=arbVotesDF,arbRoundsDF=arbRoundsDF)
										)

								)
					})
	########################################################################
	########################################################################



	########################################################################
	## Contributor Tab
	########################################################################
	output$contsd <- renderUI({list(hr(),selectizeInput("sel_cont",label="Select Donor",choices=NULL))})
	updateSelectizeInput(session = session, inputId = 'sel_cont', choices = mc_add(unique(arbVotesDF$voter)),selected="0x5f38BB373dccB91AD9Fd3727C2b9BaF6DF9332D3", server = TRUE,options= list(maxOptions = 10000))
	
	output$tabCV <- renderUI({
								layout_column_wrap(
													value_box(
																title = "Donations",
																value=paste0("$",round(sum(arbVotesDF$amountUSD[arbVotesDF$voter==input$sel_cont]),2)),
																showcase = bs_icon("cash-coin"),
																theme = "light",
																p(paste0(
																	length((arbVotesDF$amountUSD[arbVotesDF$voter==input$sel_cont])),
																	" Donations"
																)),
																p(paste0(
																	"$",
																	round(max(arbVotesDF$amountUSD[arbVotesDF$voter==input$sel_cont]),2),
																	" Max Donation"
																))
													),
													value_box(
																title = "Participation",
																value=NULL,
																showcase = bs_icon("back"),
																theme = "light",
																p(length(unique(arbVotesDF$grantAddress[arbVotesDF$voter==input$sel_cont]))," Grants"),
																p(length(unique(arbVotesDF$roundId[arbVotesDF$voter==input$sel_cont]))," Rounds"),
																p(length(unique(arbVotesDF$projectId[arbVotesDF$voter==input$sel_cont]))," Projects"),
													)
								)
					})
	output$tabCP <- renderUI({
								tprojst1 <- arbVotesDF[arbVotesDF$voter==input$sel_cont,]
								tprojst2 <- names(sort(tapply(tprojst1$amountUSD,tprojst1$projectId,sum),decreasing=TRUE))
								if(length(tprojst2)==0) return(NULL)
								tprojs <- tprojst2[1:min(length(tprojst2),12)]
								list(
										br(),
										fluidRow(column(12,h5("Top Projects Donated To (Max 12)"),align="center")),
										layout_column_wrap(
															width = 1/3,
															!!!lapply(tprojs, projc_voters,y=input$sel_cont,arbVotesDF=arbVotesDF,arbProjects=arbProjects)
										)

								)
					})
	########################################################################
	########################################################################

}