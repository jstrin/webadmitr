#' A function that returns a dataframe with one row per application for a single variable
#'
#' @param c.des_var name of the variable to extract
#' @param dfWebadmit dataframe extracted from WebAdMIT
#' @param n.variables number of designations
#' @param dfDesignation dataframe with three columns: every column name in dfWebadmit, an indicator
#' @param IDvar

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
