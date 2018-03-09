# tidy_webadmit
#
#
#

tidy_webadmit <- function(c.des_var, dfWebadmit, n.variables, dfDesignation, IDvar){

  q.des_var <- enquo( c.des_var )
  q.IDvar <- enquo( IDvar )

  l.names <- dfDesignation %>%
    filter( des_var %in% quo_name( q.des_var )) %>%
    select( l.Names ) %>%
    unlist()


  dfOut <- dfWebadmit %>%
    select( UQ( q.IDvar ), l.names ) %>%
    mutate_all( as.character ) %>%
    gather( variable, value, 2:( 1+n.variables )) %>%
    mutate( des_number = str_sub( variable, -2 )) %>%
    select( UQ( q.IDvar ), value, des_number )



  names(dfOut) <- c(IDvar, quo_name(q.des_var), "des_number")



  dfOut
}
