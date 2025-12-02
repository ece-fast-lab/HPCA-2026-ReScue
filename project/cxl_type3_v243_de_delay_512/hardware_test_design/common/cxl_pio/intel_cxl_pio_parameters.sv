// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


package intel_cxl_pio_parameters;
    parameter ENABLE_ONLY_DEFAULT_CONFIG= 0;
    parameter ENABLE_ONLY_PIO           = 0;
    parameter ENABLE_BOTH_DEFAULT_CONFIG_PIO = 1;
    parameter PFNUM_WIDTH               = 3;
    parameter VFNUM_WIDTH               = 12;
    parameter DATA_WIDTH                = 1024;
    parameter BAM_DATAWIDTH             = DATA_WIDTH;
    parameter DEVICE_FAMILY             = "Agilex";
    //parameter CXL_IO_DWIDTH = 256; // Data width for each channel
    //parameter CXL_IO_PWIDTH = 32;  // Prefix Width
    //parameter CXL_IO_CHWIDTH = 1;  // Prefix Width

endpackage
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5SOp2wqjkMCvRs5H/8cuggoPFnOYOVi/4/bu0Ttyg6RGDyAtuEiXM6zkpXTknpEbjlGv1qJhvF6QsriNG9ARPZ7JmiU3BFWTE9LqHzcFT7tPdS7N8boITkYqxt5v97iIEFF1Inp38Z2ZjsNVDWx8i62p0LDZ9g0btA81KMjFRSEqWO+7zoj3fGDFVT4C92nEu4HzJ3Vn/6UckyxLHS+UBqQ5vFQM1/jRM3utVd+aJiJvb/8qSPsjC/X5QPQhX9WLyklOss7ruoTf249fITsFPOmqn3p2A2VwKwOncKZAJ1UrZnQpFr+OOEodd1qXP8Z/6IZd52+m/GUjKFuUVcXLnwLYizvKsYmU5a/1oOvKxzWcxb7BvXE4my29Jm2jESulsZ3Vhf7YLPL5hJmdfkYvTA1N/GBdSU9yGnlS4IBhqJBlioW15ZoITJf0I3Wep629BlnkeGVqZCGUEBhalXxnGegq4r3UvD2BuI5qnA+PEYhTUoc1J9H9WMwJzxkfdi7oHxzfG29vAXrncfJaiRGOjrRgmsrqh1kRg1hhA5wAQKkfGbvsCsSPn86UeazAI/kOkccHC5xQqiAVzymB5b/QFrfEIGmKcGzZ/2Y5d1fvEk7LW8fbMP3ExlZucWw38lXj6Xy4pExstXMfFnXtfAgynTmu4GNzQSF8iTsT8r+t3IslJb3yskIGm+B83Nk7SzEs7ynkgW84gIBaUrto6ZtBLSOgqE6858QcBJqx4jwYm799jhyMvrLTGK2H3jlAjxDPCbOf+V7N3IHUkDmLoh4kZgwQ72wBX4JJQEQ9c9EeZ2cPyxu+nBtH9q5Rq+CYYD+eyqK68U+AT2LWOwX1jkCEXLzdKNgOqbdjb2L2/fvY3VSxT4amLgsY+OTL47BMaf82Fjx3F99xBs+cp6QFjQt4A73d4ojgh+3az1gsnLB1lmtWJff//m+NyMbCHlpJfQc8wlUssMYWpfOZoGmPODQggHJBJqFRWtJBy7EkTZezmSCWjUOLRiZdZtHIr1fjUqz7"
`endif