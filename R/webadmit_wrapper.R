# webadmit_wrapper
#
#
#
#

webadmit_wrapper <- function(dfWebadmit, IDvar){

  dfNames <- data.frame( l.Names = names( dfWebadmit )) %>%
    mutate( l.Names = as.character( l.Names ),
          isDesignation = grepl( "^_[0-9]$", str_sub( l.Names, -2 ))) %>%
    mutate( des_var = case_when( isDesignation ~ str_sub( l.Names, 1, -3 ),
                               !isDesignation ~ as.character( NA )),
            des_num = case_when( isDesignation ~ str_sub( l.Names, -2),
                                 !isDesignation ~ as.character ( NA )))

  l.non_designations <- dfNames %>%
    filter(!isDesignation) %>%
    select(l.Names) %>%
    unlist()

  dfDes_vars <- dfNames %>%
    filter( isDesignation ) %>%
    group_by( des_var ) %>%
    summarise( count = n() ) %>%
    ungroup()

  l.des_vars <- dfDes_vars %>%
    select( des_var ) %>%
    unlist()

  n.vars <- length( l.des_vars )

  dfDes_num <- dfNames %>%
    filter( isDesignation ) %>%
    group_by( des_num ) %>%
    summarise( count = n() ) %>%
    mutate( correct = count == n.vars)

  n.des <- nrow( dfDes_num )

  dfDes_vars <- dfDes_vars %>%
    mutate( correct = count == n.des )

  stopifnot( min( dfDes_vars$correct ) == 1 )
  stopifnot( min( dfDes_num$correct ) == 1 )


  l.df <- map( l.des_vars, tidy_webadmit, dfWebadmit = dfWebadmit, n.variables = n.vars, dfDesignation = dfNames, IDvar = IDvar )

  dfDes_vars <- reduce(l.df, left_join, (by = c( IDvar, "des_number" )))




   dfOut <- dfWebadmit %>%
     select( IDvar, l.non_designations ) %>%
     mutate_all( as.character ) %>%
     left_join( dfDes_vars, by = c( IDvar ))




  # l.dfout <- list(dfNames, dfDes_vars, l.des_vars, n.vars, dfDes_num, l.df, dfDes_vars, dfOut)

  # l.dfout

   dfOut

}
