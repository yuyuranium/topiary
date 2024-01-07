package OboeFreeList;

import Vector::*;
import Assert::*;

import OboeTypeDef::*;
import OboeConfig::*;

// Interface: OboeFreeList
//   Scheduler uses the interface to allocate an entry for register renaming or commit and free and
//   entry when instruction retired.
interface OboeFreeList;
  // Method: allocate
  //   Allocate an entry from the ROB or physical register file.
  //
  // Return:
  //   Tag to the allocated entry.
  method ActionValue#(Tag) allocate();
  // Method: commitAndFree
  //   Commit an entry and free an entry simultaneously.
  //
  // Parameter:
  //   commit_ptr - Tag to the entry to commit.
  //   to_free    - Tag to the entry to be freed.
  //
  // Return:
  //   Tag of the entry to commit next.
  method ActionValue#(Tag) commitAndFree(Tag commit_ptr, Tag to_free);
endinterface

// Module: mkOboeFreeList
//   Free list implementation to maintain a list of free ROB/physical register file entries.
module mkOboeFreeList (OboeFreeList);
  // Function: genInitialValue
  //   First kNumArchRegs entries are allocated to the architectural registers when reset. The
  //   remaining entries has initial value that points to the next entry. The tag of in-use
  //   entries is assigned to its tag id.
  function Tag genInitialValue(Integer i) =
      (i >= kNumArchRegs && i < kNumPhysicalRegs) ? fromInteger(i) + 1 : fromInteger(i);

  // Object: next
  //   Vector of registers to store the next free entry.
  Vector#(NumPhysicalRegs, Reg#(Tag)) next <- mapM(mkReg, map(genInitialValue, genVector));

  // Function: isInUse
  //   Indicate the entry pointed by the tag is in use or not.
  function Bool isInUse(Tag tag) = next[tag] == tag;

  // Function: markInUse
  //   Action to mark the entry as in use.
  function Action markInUse(Tag tag) =
      action
        next[tag] <= tag;
      endaction;

  // Function: markFree
  //   Action to mark the entry as free (not in use).
  function Action markFree(Tag tag) =
      action
        next[tag] <= 0;
      endaction;

  // Object: free_ptr
  //   Free pointer indicates the next free entry, initially points to the first free entry.
  Reg#(Tag) free_ptr <- mkReg(fromInteger(kNumArchRegs));

  // Object: null_ptr
  //   Null pointer indicates the last free entry, initially points to the last entry.
  Reg#(Tag) null_ptr <- mkReg(fromInteger(kNumPhysicalRegs - 1));

  // Bool: is_full
  //   Entries are used up when <free_ptr> reaches <null_ptr>.
  Bool is_full = free_ptr == null_ptr;

  method ActionValue#(Tag) allocate() if (!is_full);
    // Advance the free pointer
    free_ptr <= next[free_ptr];
    // Return the free pointer as the allocated entry
    return free_ptr;
  endmethod

  method ActionValue#(Tag) commitAndFree(Tag commit_ptr, Tag to_free);
    dynamicAssert(isInUse(to_free), "Entry to free must be in-use");
    // Append the freed entry to the list
    next[null_ptr] <= to_free;
    // Redirect null pointer to the newly freed entry
    null_ptr <= to_free;
    // Ensure all writes to the next vector are conflict free
    if (commit_ptr != null_ptr && to_free != null_ptr && commit_ptr != to_free) begin
      // Mark the entry to free as free
      markFree(to_free);
      // Mark the committed entry as in-use
      markInUse(commit_ptr);
    end else begin
      dynamicAssert(False, "Conflict in commit_ptr, to_free, and null_ptr");
    end
    return next[commit_ptr];
  endmethod

endmodule

endpackage
