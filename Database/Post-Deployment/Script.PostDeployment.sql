-- Post-Deployment Script: Seed Initial Data (States, Cities, Hobbies)
-- ======================================================================

-- States
IF NOT EXISTS (SELECT 1 FROM [dbo].[States])
BEGIN
    INSERT INTO [dbo].[States] ([StateName]) VALUES
        ('Andhra Pradesh'),
        ('Assam'),
        ('Bihar'),
        ('Chhattisgarh'),
        ('Delhi'),
        ('Goa'),
        ('Gujarat'),
        ('Haryana'),
        ('Himachal Pradesh'),
        ('Jharkhand'),
        ('Karnataka'),
        ('Kerala'),
        ('Madhya Pradesh'),
        ('Maharashtra'),
        ('Manipur'),
        ('Meghalaya'),
        ('Odisha'),
        ('Punjab'),
        ('Rajasthan'),
        ('Tamil Nadu'),
        ('Telangana'),
        ('Uttar Pradesh'),
        ('Uttarakhand'),
        ('West Bengal');
END
GO

-- Cities
IF NOT EXISTS (SELECT 1 FROM [dbo].[Cities])
BEGIN
    -- Gujarat (StateId=7)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (7, 'Ahmedabad'), (7, 'Surat'), (7, 'Vadodara'), (7, 'Rajkot'),
        (7, 'Gandhinagar'), (7, 'Bhavnagar'), (7, 'Jamnagar'), (7, 'Surendranagar');

    -- Maharashtra (StateId=14)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (14, 'Mumbai'), (14, 'Pune'), (14, 'Nagpur'), (14, 'Nashik'),
        (14, 'Aurangabad'), (14, 'Solapur'), (14, 'Kolhapur'), (14, 'Thane');

    -- Delhi (StateId=5)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (5, 'New Delhi'), (5, 'Dwarka'), (5, 'Rohini'), (5, 'Janakpuri'),
        (5, 'Saket'), (5, 'Karol Bagh'), (5, 'Connaught Place'), (5, 'Lajpat Nagar');

    -- Karnataka (StateId=11)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (11, 'Bangalore'), (11, 'Mysore'), (11, 'Hubli'), (11, 'Mangalore'),
        (11, 'Belgaum'), (11, 'Shimoga'), (11, 'Davangere'), (11, 'Tumkur');

    -- Tamil Nadu (StateId=20)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (20, 'Chennai'), (20, 'Coimbatore'), (20, 'Madurai'), (20, 'Salem'),
        (20, 'Tiruchirappalli'), (20, 'Tiruppur'), (20, 'Erode'), (20, 'Vellore');

    -- Uttar Pradesh (StateId=22)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (22, 'Lucknow'), (22, 'Kanpur'), (22, 'Agra'), (22, 'Varanasi'),
        (22, 'Prayagraj'), (22, 'Noida'), (22, 'Meerut'), (22, 'Ghaziabad');

    -- Rajasthan (StateId=19)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (19, 'Jaipur'), (19, 'Jodhpur'), (19, 'Udaipur'), (19, 'Ajmer'),
        (19, 'Kota'), (19, 'Bikaner'), (19, 'Alwar'), (19, 'Bharatpur');

    -- West Bengal (StateId=24)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (24, 'Kolkata'), (24, 'Siliguri'), (24, 'Durgapur'), (24, 'Asansol'),
        (24, 'Howrah'), (24, 'Bardhaman'), (24, 'Malda'), (24, 'Kharagpur');

    -- Punjab (StateId=18)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (18, 'Chandigarh'), (18, 'Ludhiana'), (18, 'Amritsar'), (18, 'Jalandhar'),
        (18, 'Patiala'), (18, 'Bathinda'), (18, 'Mohali'), (18, 'Pathankot');

    -- Telangana (StateId=21)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (21, 'Hyderabad'), (21, 'Warangal'), (21, 'Nizamabad'), (21, 'Karimnagar'),
        (21, 'Khammam'), (21, 'Ramagundam'), (21, 'Mahabubnagar'), (21, 'Nalgonda');

    -- Kerala (StateId=12)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (12, 'Thiruvananthapuram'), (12, 'Kochi'), (12, 'Kozhikode'), (12, 'Thrissur'),
        (12, 'Kollam'), (12, 'Palakkad'), (12, 'Alappuzha'), (12, 'Kannur');

    -- Madhya Pradesh (StateId=13)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (13, 'Bhopal'), (13, 'Indore'), (13, 'Jabalpur'), (13, 'Gwalior'),
        (13, 'Ujjain'), (13, 'Sagar'), (13, 'Dewas'), (13, 'Satna');

    -- Bihar (StateId=3)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (3, 'Patna'), (3, 'Gaya'), (3, 'Bhagalpur'), (3, 'Muzaffarpur'),
        (3, 'Purnia'), (3, 'Darbhanga'), (3, 'Ara'), (3, 'Begusarai');

    -- Andhra Pradesh (StateId=1)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (1, 'Visakhapatnam'), (1, 'Vijayawada'), (1, 'Guntur'), (1, 'Nellore'),
        (1, 'Kurnool'), (1, 'Kakinada'), (1, 'Tirupati'), (1, 'Rajahmundry');

    -- Haryana (StateId=8)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (8, 'Gurugram'), (8, 'Faridabad'), (8, 'Panipat'), (8, 'Ambala'),
        (8, 'Hisar'), (8, 'Rohtak'), (8, 'Karnal'), (8, 'Sonipat');

    -- Goa (StateId=6)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (6, 'Panaji'), (6, 'Margao'), (6, 'Vasco da Gama'), (6, 'Mapusa'),
        (6, 'Ponda'), (6, 'Bicholim'), (6, 'Curchorem'), (6, 'Sanquelim');

    -- Assam (StateId=2)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (2, 'Guwahati'), (2, 'Silchar'), (2, 'Dibrugarh'), (2, 'Jorhat'),
        (2, 'Nagaon'), (2, 'Tinsukia'), (2, 'Lakhimpur'), (2, 'Tezpur');

    -- Odisha (StateId=17)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (17, 'Bhubaneswar'), (17, 'Cuttack'), (17, 'Rourkela'), (17, 'Brahmapur'),
        (17, 'Sambalpur'), (17, 'Puri'), (17, 'Balasore'), (17, 'Bhadrak');

    -- Uttarakhand (StateId=23)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (23, 'Dehradun'), (23, 'Haridwar'), (23, 'Roorkee'), (23, 'Rishikesh'),
        (23, 'Kashipur'), (23, 'Rudrapur'), (23, 'Haldwani'), (23, 'Mussoorie');

    -- Himachal Pradesh (StateId=9)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (9, 'Shimla'), (9, 'Manali'), (9, 'Dharamshala'), (9, 'Kullu'),
        (9, 'Mandi'), (9, 'Solan'), (9, 'Baddi'), (9, 'Una');

    -- Chhattisgarh (StateId=4)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (4, 'Raipur'), (4, 'Bhilai'), (4, 'Durg'), (4, 'Bilaspur'),
        (4, 'Korba'), (4, 'Rajnandgaon'), (4, 'Jagdalpur'), (4, 'Raigarh');

    -- Jharkhand (StateId=10)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (10, 'Ranchi'), (10, 'Jamshedpur'), (10, 'Dhanbad'), (10, 'Bokaro'),
        (10, 'Hazaribagh'), (10, 'Deoghar'), (10, 'Giridih'), (10, 'Ramgarh');

    -- Meghalaya (StateId=16)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (16, 'Shillong'), (16, 'Tura'), (16, 'Jowai'), (16, 'Nongstoin');

    -- Manipur (StateId=15)
    INSERT INTO [dbo].[Cities] ([StateId], [CityName]) VALUES
        (15, 'Imphal'), (15, 'Thoubal'), (15, 'Bishnupur'), (15, 'Churachandpur');
END
GO

-- Hobbies
IF NOT EXISTS (SELECT 1 FROM [dbo].[Hobbies])
BEGIN
    INSERT INTO [dbo].[Hobbies] ([HobbyName]) VALUES
        ('Reading'),
        ('Cricket'),
        ('Football'),
        ('Music'),
        ('Travel'),
        ('Gaming'),
        ('Photography'),
        ('Coding'),
        ('Drawing'),
        ('Cooking'),
        ('Dancing'),
        ('Yoga');
END
GO
