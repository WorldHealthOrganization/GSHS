##NOTE: When working with rstudio interface - please uncomment line 170 and comment line 171

####Detailed tables#
detailed_tab_fn = function(std_var ='DB_HUNGRY')
{
  formula = make.formula(std_var)

  cond_output = function(condition =  "age_cat=='12 or younger'")
  {
    if (condition =='')
    {
      tab_output =  data %>%
        dplyr::reframe(label_names = names(table(eval(parse(text = std_var)))),
                       unweighted_freq = table(eval(parse(text = std_var))),
                       weighted_perc = formatC(round(prop.table(svytable(formula,design = svy_data))*100,1),format = 'f', digits = 1)) %>%
        mutate(unweighted_freq = as.character(unweighted_freq)) %>%
        tidyr::pivot_longer(cols=c(weighted_perc,unweighted_freq)) %>% select(-name) %>%
        mutate(label_names = as.character(label_names), value = as.character(value)) %>% as.data.frame()%>%
        bind_rows(data.frame(label_names = eval(parse(text=lang_titles[4])), value ='100%'))%>%
        bind_rows(data.frame(label_names = eval(parse(text=lang_titles[4])), value = eval(parse(text=paste0('sum(table(data$',std_var,'), na.rm = T)'))))%>%
                    mutate(label_names = as.character(label_names), value = as.character(value)))
    }
    else
    {
      tab_output =  eval(parse(text=paste0('data %>% dplyr::filter (', condition,')')))%>%
        dplyr::reframe(label_names = names(table(eval(parse(text = std_var)))),
                       unweighted_freq = table(eval(parse(text = std_var))),
                       weighted_perc = formatC(round(prop.table(svytable(formula,design = subset(svy_data,eval(parse(text=condition)))))*100,1),format = 'f', digits = 1)) %>%
        mutate(unweighted_freq = as.character(unweighted_freq)) %>%
        tidyr::pivot_longer(cols=c(weighted_perc,unweighted_freq)) %>% select(-name)%>%
        mutate(label_names = as.character(label_names), value = as.character(value)) %>% as.data.frame()%>%
        bind_rows(data.frame(label_names = eval(parse(text=lang_titles[4])), value ='100%'))%>%
        bind_rows(data.frame(label_names = eval(parse(text=lang_titles[4])), eval(parse(text=paste0('data %>% dplyr::filter (', condition,')'))) %>%
                               reframe(eval(parse(text = paste0('sum(table(',std_var,'),na.rm=T)'))))) %>%
                    rename(value ='eval.parse.text...paste0..sum.table....std_var.....na.rm.T.....') %>%
                    mutate(label_names = as.character(label_names), value = as.character(value)))
    }
    ###Formatting and restricting outputs where subgroup >=n_cutoff
    tab_output$value[seq(1,nrow(tab_output),2)][as.numeric(tab_output$value[nrow(tab_output)])< n_cutoff]=' - '

    return(tab_output)
  }

  ###Calling cond_output function::Total
  total_conditions = c('',"age_cat=='12 or younger'", "age_cat=='13 - 15'","age_cat=='16 or 17'",
                       "age_cat=='13 - 15'|age_cat=='16 or 17'", "age_cat=='18 or older'",
                       paste0("DE_GRADE =='", levels(data$DE_GRADE),"'"))
  eval(parse(text=paste0('total_res = cbind(',paste0('cond_output("',total_conditions,'")[,2]', collapse = ','),')')))
  #
  mod_total_res = rbind(c(eval(parse(text=lang_titles[4])),'','',eval(parse(text=lang_titles[20])),'','','','',eval(parse(text=lang_titles[11])),rep('', length(levels(data$DE_GRADE))-1)),
                          c('','',eval(parse(text=lang_titles[4])),eval(parse(text=lang_titles[6])),'13-15','16-17','13-17',eval(parse(text=lang_titles[9])), gsub('*.        ','',levels(data$DE_GRADE))),
                          cond_output(total_conditions[1])[,1] %>%bind_cols(rep(c('%','N'),nrow(total_res)/2),total_res))
  ###
  
  ###
  if(language =='FRENCH')
  {
    mod_total_res = eval(parse(text=paste0('cbind(',paste0(gsub('\\.',',',mod_total_res), collapse =','),')'))) %>% as.data.frame()
  }else{}
  
  flex_total_res =  mod_total_res %>% flextable() %>% autofit() %>%
    delete_part(part = "header") %>% 
    add_header_lines(paste0(std_var,': ',label(eval(parse(text=paste0('data$',std_var)))),'\n'))%>%
    flextable::style(pr_t=fp_text(font.family='Source Sans Pro'), part = 'all')%>%
    bold(i = 1:2)%>%
    bg(bg="white",i=1,part="header")%>%
    hline_top(border = fp_border_default(width = 0),part = "header")%>%
    vline_left(i=1,border = fp_border_default(width = 0),part = "header")%>%
    vline(i=1,border = fp_border_default(width = 0),part = "header")%>%
    fontsize(size = 8 ,part = "all") %>%
    merge_v(j = 1) %>% valign(valign = 'top')%>%
    align(j = 3:ncol(mod_total_res),align = 'right', part = 'all') %>%
    line_spacing(i = 3:nrow(mod_total_res), space = 0.7, part = "body") %>%
    fix_border_issues()%>% width(j = 4, 1, unit = "in")

  ##Males
  male_conditions = c(paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"'"),
                      paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & age_cat=='12 or younger'"),
                      paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & age_cat=='13 - 15'"),
                      paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & age_cat=='16 or 17'"),
                      paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & (age_cat=='13 - 15'|age_cat=='16 or 17')"),
                      paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & age_cat=='18 or older'"),
                      paste0(paste0('DE_SEX == ',"'", levels(data$DE_SEX)[1],"' & "), "DE_GRADE =='", levels(data$DE_GRADE),"'"))

  eval(parse(text=paste0('male_res = cbind(',paste0('cond_output("',male_conditions,'")[,2]', collapse = ','),')')))
  #
  mod_male_res = rbind(c(eval(parse(text=lang_titles[12])),'','',eval(parse(text=lang_titles[20])),'','','','',
                         eval(parse(text=lang_titles[11])),rep('', length(levels(data$DE_GRADE))-1)),
                       c(eval(parse(text=lang_titles[16])), gsub('*.        ','',levels(data$DE_GRADE))),
                       cond_output(male_conditions[1])[,1] %>%
                         bind_cols(rep(c('%','N'),nrow(male_res)/2),male_res))
 
  ####
  ###
  if(language =='FRENCH')
  {
    mod_male_res = eval(parse(text=paste0('cbind(',paste0(gsub('\\.',',',mod_male_res), collapse =','),')'))) %>% as.data.frame()
  }else{}
  
  

  flex_male_res = mod_male_res %>% flextable() %>% autofit() %>%
    delete_part(part = "header") %>% 
    add_header_lines(paste0(std_var,': ',label(eval(parse(text=paste0('data$',std_var)))),'\n'))%>%
    flextable::style(pr_t=fp_text(font.family='Source Sans Pro'), part = 'all')%>%
    bold(i = 1:2)%>%
    bg(bg="white",i=1,part="header")%>%
    hline_top(border = fp_border_default(width = 0),part = "header")%>%
    vline_left(i=1,border = fp_border_default(width = 0),part = "header")%>%
    vline(i=1,border = fp_border_default(width = 0),part = "header")%>%
    fontsize(size = 8 ,part = "all") %>%
    merge_v(j = 1) %>% valign(valign = 'top')%>%
    align(j = 3:ncol(mod_male_res),align = 'right', part = 'all') %>%
    line_spacing(i = 3:nrow(mod_male_res), space = 0.7, part = "body") %>%
    fix_border_issues()%>% width(j = 4, 1, unit = "in")

  ###Females
  female_conditions = c(paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"'"),
                        paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & age_cat=='12 or younger'"),
                        paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & age_cat=='13 - 15'"),
                        paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & age_cat=='16 or 17'"),
                        paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & (age_cat=='13 - 15'|age_cat=='16 or 17')"),
                        paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & age_cat=='18 or older'"),
                        paste0(paste0('DE_SEX == ',"'", levels(data$DE_SEX)[2],"' & "), "DE_GRADE =='", levels(data$DE_GRADE),"'"))

  eval(parse(text=paste0('female_res = cbind(',paste0('cond_output("',female_conditions,'")[,2]', collapse = ','),')')))
  #
  
  mod_female_res = rbind(c(eval(parse(text=lang_titles[13])),'','',eval(parse(text=lang_titles[20])),'','','','',eval(parse(text=lang_titles[11])),rep('', length(levels(data$DE_GRADE))-1)),
                         c(eval(parse(text=lang_titles[17])), gsub('*.        ','',levels(data$DE_GRADE))),
                         cond_output(female_conditions[1])[,1] %>%
                           bind_cols(rep(c('%','N'),nrow(female_res)/2),female_res))
  
  ##
  ####
  if(language =='FRENCH')
  {
    mod_female_res = eval(parse(text=paste0('cbind(',paste0(gsub('\\.',',',mod_female_res), collapse =','),')'))) %>% as.data.frame()
  }else{}
  
##

  flex_female_res = mod_female_res %>% flextable() %>% autofit() %>%
    delete_part(part = "header") %>% 
    add_header_lines(paste0(std_var,': ',label(eval(parse(text=paste0('data$',std_var)))),'\n'))%>%
    flextable::style(pr_t=fp_text(font.family='Source Sans Pro'), part = 'all')%>%
    bold(i = 1:2)%>%
    bg(bg="white",i=1,part="header")%>%
    hline_top(border = fp_border_default(width = 0),part = "header")%>%
    vline_left(i=1,border = fp_border_default(width = 0),part = "header")%>%
    vline(i=1,border = fp_border_default(width = 0),part = "header")%>%
    fontsize(size = 8 ,part = "all") %>%
    merge_v(j = 1) %>% valign(valign = 'top')%>%
    align(j = 3:ncol(mod_female_res),align = 'right', part = 'all') %>%
    #merge_h_range(j1=9, j2=10)%>%align(j = 9, align = 'left') %>%
    line_spacing(i = 3:nrow(mod_female_res), space = 0.7, part = "body") %>%
    fix_border_issues()%>% width(j = 4, 1, unit = "in")#%>% width(j = 3, 1, unit = "in")

  ###All flextable outputs
  eval(parse(text=paste0(std_var,'_flex_detailed = list(flex_total_res,flex_male_res,flex_female_res)')))
}

###calling detailed_tab_fn
#
vars_for_detailed_tables = setdiff(standard_variables, c("DE_AGE","DE_SEX","DE_GRADE","DB_HEIGHT","DB_WEIGHT"))

# cl = makeCluster(num_cores)
# detailed_tables <<- parallel::mclapply(vars_for_detailed_tables, detailed_tab_fn, mc.cores = num_cores, mc.preschedule = FALSE)
# stopCluster(cl)
#detailed_tables = future.apply::future_lapply(vars_for_detailed_tables, detailed_tab_fn,future.seed=TRUE)
detailed_tables = lapply(vars_for_detailed_tables, detailed_tab_fn)

final_detailed_tables <<- unlist(detailed_tables, recursive = FALSE)


##############
# Function to add a Flextable with a break at the end
i = NULL
for (i in 1:length(final_detailed_tables)) {
  if(weighted_reporting=='Yes'){
    my_doc = read_docx(paste0(getwd(),'/templates/',language,'/detailed_tables_template.docx'))
  }else{
    my_doc = read_docx(paste0(getwd(),'/templates/',language,'/UNWEIGHTED/detailed_tables_template.docx'))  
  }
  if (i < length(final_detailed_tables))
  {
    my_doc = my_doc %>%
      body_add_flextable(width(final_detailed_tables[[i]], width = dim(final_detailed_tables[[i]])$widths*10/(flextable_dim(final_detailed_tables[[i]])$widths)),pos = 'on')%>% 
      body_add_break()  
  }
  else
  {
    my_doc = my_doc %>%
      body_add_flextable(width(final_detailed_tables[[i]], width = dim(final_detailed_tables[[i]])$widths*10/(flextable_dim(final_detailed_tables[[i]])$widths)),pos = 'on') 
  }
  #
  print(my_doc,target=paste0(getwd(),'/temp_tables/tempdetailed',i,'.docx')) 
}

#observe({
if(weighted_reporting=='Yes'){
combined_detailed_doc <<- read_docx(paste0(getwd(),'/templates/',language,'/detailed_tables_template.docx'))
}else{
  combined_detailed_doc <<- read_docx(paste0(getwd(),'/templates/',language,'/UNWEIGHTED/detailed_tables_template.docx'))
}
combined_detailed_doc <<- headers_replace_text_at_bkm(combined_detailed_doc,"country",site_name)
combined_detailed_doc <<- headers_replace_text_at_bkm(combined_detailed_doc,"year",survey_year)
#})

i=NULL
for(i in rev(1:length(final_detailed_tables))){
  path <- paste0(getwd(),'/temp_tables/tempdetailed',i,'.docx')
  detaileddoc <<- body_add_docx(combined_detailed_doc, path, pos = "after") 
}

# print combine doc
#observe({
print(detaileddoc,target=paste0(getwd(),'/Reports/',survey_year,' ' ,site_name,' Detailed Tables.docx')) 
#})

