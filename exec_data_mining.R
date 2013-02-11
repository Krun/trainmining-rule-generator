source('validation.R')
source('cspade_wrapper.R')
source('create_baskets_k-fold.R')

path_sequences <- "/opt/adrian/r-output/sequences/"

execute_all <- function(name,target,days,sp,gap,msize,k=10) {
  params=list(support=sp, mingap=gap, maxgap=gap, maxlen=2, maxsize=msize)
  create_k_basket_files(target,name,k,"baskets/",days)
  cspade_k_fold(name,k,"baskets/",path_sequences,params)
  auto_k_validate(name, k, winmax=gap, winmin=gap, path=path_sequences,minprec=0.1)
  av <- k_average(name,k)
}