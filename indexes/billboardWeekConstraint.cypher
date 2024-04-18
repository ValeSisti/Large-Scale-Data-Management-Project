//billboardWeekConstraint
CREATE CONSTRAINT billboardWeekConstraint FOR (b:BillboardWeek) REQUIRE b.week_of_date IS UNIQUE