# Rscript scripts/analysis_overview_figures.R
library(ggplot2)
library(dplyr)
root <- path.expand('~/dev/effect-measure-stability')
script <- sub('^--file=', '', grep('^--file=', commandArgs(), value=TRUE)[1])
out <- file.path(dirname(dirname(normalizePath(script))), 'figs', 'analysis-overview')
dir.create(out, recursive=TRUE, showWarnings=FALSE)
theme_set(theme_classic(base_size=17) + theme(plot.title=element_text(size=21), legend.position='bottom', plot.margin=margin(12,15,12,12)))
save_plot <- function(p, name, w=10, h=5) {
  for(ext in c('png','svg')) ggsave(file.path(out,paste0(name,'.',ext)),p,width=w,height=h,dpi=180,bg='white')
}
a <- read.csv(file.path(root,'output/tables/primary_results.csv'))
h <- bind_rows(transmute(a, estimator, result='Matched lower', proportion=pct_correct_lower), transmute(a,estimator,result='Tied',proportion=pct_tied), transmute(a,estimator,result='Matched higher',proportion=1-pct_correct_lower-pct_tied))
h$result <- factor(h$result,c('Matched lower','Tied','Matched higher'))
p <- ggplot(h,aes(estimator,proportion,fill=result)) + geom_col(position=position_stack(reverse=TRUE),width=.6) + geom_text(aes(label=sprintf('%.1f%%',100*proportion)),position=position_stack(vjust=.5,reverse=TRUE),size=5) + scale_fill_manual(values=c('#56B4E9','#CCD1D6','#E69F00')) + scale_y_continuous(labels=scales::label_percent()) + scale_x_discrete(labels=c(glmm='GLMM-based',metabin='REML on log ratios')) + labs(title='Heterogeneity comparison in 104 MAs',x=NULL,y='Percentage of meta-analyses',fill=NULL)
save_plot(p,'heterogeneity')

r <- read.csv(file.path(root,'output/independent_binomial_coupling_direction_v2/report/evaluation/recovery.csv'))
r <- r |> filter(scenario=='mechanism_010_0.8__perfect',prior==2,estimand %in% c('S_rr_0','S_sr_0','S_rr_1','S_sr_1'))
stopifnot(nrow(r)==4)
r$target <- factor(r$estimand,levels=c('S_rr_0','S_sr_0','S_rr_1','S_sr_1'),labels=c('Decrease: RR\nmatched','Decrease: SR\nmismatched','Increase: RR\nmismatched','Increase: SR\nmatched'))
p <- ggplot(r,aes(target)) + geom_hline(yintercept=0,color='grey65') + geom_segment(aes(xend=target,y=truth_mean,yend=posterior_mean),color='grey50',linewidth=1) + geom_point(aes(y=truth_mean,color='Truth'),shape=4,size=4,stroke=1.5) + geom_point(aes(y=posterior_mean,color='Mean estimate'),size=3.5) + scale_color_manual(values=c('Truth'='black','Mean estimate'='#D55E00')) + labs(title='Coupling recovery when the assumptions hold',subtitle='Constant mechanism 0.10; broad baseline spread; correct direction labels',x=NULL,y='Coupling slope',color=NULL,caption='200 replicates; 35-MA empirical design; independent Beta(2,2) arm models.')
save_plot(p,'coupling-recovery',11,5)

s <- read.csv(file.path(root,'output/new_rct_prediction/v1/results/performance_contrasts.csv')) |>
 filter(prior_variant=='base',shift==0,baseline_mode=='count',direction_group %in% c('decrease','increase'), comparator=='opposite',scenario %in% c('C2','V1','V4','O1'))
stopifnot(nrow(s)==8)
s$scenario <- factor(s$scenario,levels=c('C2','V1','V4','O1'),labels=c('Constant mechanism','Varying mechanism','20% direction errors','Constant OR'))
p <- ggplot(s,aes(scenario,improvement_latent_mean*10000)) + geom_hline(yintercept=0,linetype='dashed',color='grey50') + geom_errorbar(aes(ymin=improvement_latent_lower*10000,ymax=improvement_latent_upper*10000),width=.15) + geom_point(color='#0072B2',size=3) + facet_wrap(~direction_group,ncol=1,scales='free_y') + labs(title='Prediction gains depend on the generator',subtitle='Opposite-scale MSE minus matched-scale MSE; positive favors matching',x=NULL,y='MSE improvement (pp²)',caption='400 evaluation collections per setting; target control counts available; 95% Monte Carlo intervals.') + theme(axis.text.x=element_text(size=12))
save_plot(p,'prediction-simulation',11,6)

v <- read.csv(file.path(root,'output/monotonicity_validation/v3/real_ma_results.csv')) |> filter(group=='monotonic') |> arrange(adv_or) |> mutate(rank=row_number())
stopifnot(nrow(v)==31)
p <- ggplot(v,aes(rank,adv_or*10000,fill=adv_or>0)) + geom_col(show.legend=FALSE) + geom_hline(yintercept=0,color='grey40') + scale_fill_manual(values=c('FALSE'='#D55E00','TRUE'='#0072B2')) + labs(title='Constant-effect prediction: 31 likely/certain MAs',subtitle='OR MSE minus matched-scale MSE; positive favors matching',x='Meta-analysis, ordered by predictive advantage',y='MSE improvement (pp²)',caption=sprintf('%d/31 favor matching; equal-MA mean = %.2f. Descriptive results.',sum(v$adv_or>0),mean(v$adv_or)*10000))
save_plot(p,'constant-effect-prediction',11,5)
