package fi.koku.tools.dataimport;

import java.io.File;
import java.io.FileReader;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

import au.com.bytecode.opencsv.CSVReader;

public class DataImporter {

  private static final int HELMI_CUSTOMER_PIC = 5;
  private static final int EFFICA_CUSTOMER_PIC = 4;
  private static final int EMPLOYEE_PIC = 3;
  private static final int HELMI_CUSTOMER = 2;
  private static final int EFFICA_CUSTOMER = 1;
  private static final int EMPLOYEE = 0;

  public static void main(String[] args) throws Exception {
    try {
      new DataImporter(args);
    } catch (Exception e) {      
      e.printStackTrace();
      JOptionPane.showMessageDialog(null, "There was an error executing the dataimport. " +
      		"Please check the console.\nException: " + e.getMessage());     
    }
  }

  public DataImporter(String[] args) throws Exception {

    Object[] options = new Object[] { "Employee", "Effica customer", "Helmi customer", "Employee PICs",
        "Effica customer PICs", "Helmi customer PICs" };
    int returnvalue = JOptionPane.showOptionDialog(null, "Select file type.", null, JOptionPane.DEFAULT_OPTION,
        JOptionPane.QUESTION_MESSAGE, null, options, options[0]);

    if (returnvalue != EMPLOYEE && returnvalue != EFFICA_CUSTOMER && returnvalue != HELMI_CUSTOMER &&
        returnvalue != EMPLOYEE_PIC && returnvalue != EFFICA_CUSTOMER_PIC && returnvalue != HELMI_CUSTOMER_PIC) {
      JOptionPane.showMessageDialog(null, "No file type selected, exiting.");
      return;
    }

    JFileChooser chooser = new JFileChooser(new File("c:/users/hanhian/desktop"));
    chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
    int result = chooser.showOpenDialog(null);

    if (result == JFileChooser.APPROVE_OPTION) {
      WSCaller caller = new WSCaller();
      File file = chooser.getSelectedFile();

      // User selected Employee
      if (returnvalue == EMPLOYEE) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new LDIFWriter().writeEmployeeLDIF(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }
      // Effica Customer
      } else if (returnvalue == EFFICA_CUSTOMER) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new LDIFWriter().writeEfficaCustomerLDIF(reader, file.getParentFile());
        } finally {
          reader.close();
        }

        reader = new CSVReader(new FileReader(file));        
        try {
          new CustomerCreator().createEfficaCustomers(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }
        // Helmi Customer
      } else if (returnvalue == HELMI_CUSTOMER) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new LDIFWriter().writeHelmiCustomerLDIF(reader, file.getParentFile());
        } finally {
          reader.close();
        }

        reader = new CSVReader(new FileReader(file));
        try {
          new CustomerCreator().createHelmiCustomers(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }

      // Employee Hetu
      } else if (returnvalue == EMPLOYEE_PIC) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new PICWriter().writeEmployeePICFile(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }

      // Effica Customer Hetu
      } else if (returnvalue == EFFICA_CUSTOMER_PIC) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new PICWriter().writeEfficaCustomerPICFile(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }     
      
     // Helmi Customer Hetu
      } else if (returnvalue == HELMI_CUSTOMER_PIC) {
        CSVReader reader = new CSVReader(new FileReader(file));
        try {
          new PICWriter().writeHelmiCustomerPICFile(reader, caller, file.getParentFile());
        } finally {
          reader.close();
        }
      }

      System.out.println("Done.");
    }
  }
}