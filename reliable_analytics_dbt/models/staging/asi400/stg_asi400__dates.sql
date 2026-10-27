select
    keyDate as date_key,
    julianDate as legacy_date_key,
    calendarDate as calendar_date,
    calendarYear as calendar_year,
    calendarMonth as calendar_month,
    calendarDay as calendar_day,
    calendarDayOfYear as calendar_day_of_year,
    fiscalYear as fiscal_year,
    fiscalPeriod as fiscal_period,
    fiscalWeek as fiscal_week,
    dayOfWeek as day_of_week,
    dayName as day_name,
    monthName as month_name,
    workDay as work_day,
    businessDay as business_day

from {{ source('asi400', 'DimDate') }}