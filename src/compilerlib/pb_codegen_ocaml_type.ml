(*
  The MIT License (MIT)
  
  Copyright (c) 2016 Maxime Ransan <maxime.ransan@gmail.com>
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*)

(** OCaml type representation *)

module Pt = Pb_parsing_parse_tree

type payload_kind = 
  | Pk_varint of bool (** zigzag *)  
  | Pk_bits32
  | Pk_bits64
  | Pk_bytes 

type user_defined_type = {
  udt_module : string option; 
  udt_type_name : string; 
  udt_nested : bool; 
    (* The nested property indicate whether this [user_defined_type] requires 
     * a nested decoder. For types which serialize to a message it will be 
     * true (ie message in protobuf) but for enum types it won't. 
     *)
}

type basic_type = 
  | Bt_string 
  | Bt_float 
  | Bt_int 
  | Bt_int32 
  | Bt_int64
  | Bt_bytes
  | Bt_bool

type field_type = 
  | Ft_unit
  | Ft_basic_type        of basic_type
  | Ft_user_defined_type of user_defined_type

type default_value = Pt.constant option 

type associative_type  = 
  | At_list
  | At_hashtable
  (* Future work can include the following OCaml associative containers
  | Al_map
  *)

type repeated_type = 
  | Rt_list
  | Rt_repeated_field

type encoding_number = int 

type is_packed = bool 

type record_field_type = 
  | Rft_nolabel         of (field_type * encoding_number * payload_kind) 
                           (* no default values in proto3 no label fields *)

  | Rft_required        of (field_type * encoding_number * payload_kind * default_value)  
  
  | Rft_optional        of (field_type * encoding_number * payload_kind * default_value) 

  | Rft_repeated_field  of (repeated_type* field_type * encoding_number * payload_kind * is_packed)  

  | Rft_associative_field of (associative_type           * 
                              encoding_number            * 
                             (basic_type * payload_kind) * 
                             (field_type * payload_kind))

  | Rft_variant_field     of variant 

and variant_constructor = {
  vc_constructor : string ; 
  vc_field_type : variant_constructor_type; 
  vc_encoding_number : encoding_number; 
  vc_payload_kind: payload_kind; 
}

and variant_constructor_type = 
  | Vct_nullary 
  | Vct_non_nullary_constructor of field_type 

and variant = {
  v_name : string; 
  v_constructors : variant_constructor list; 
}

and record_field = {
  rf_label : string; 
  rf_field_type : record_field_type;
  rf_mutable : bool;
}

and record = {
  r_name : string; 
  r_fields : record_field list; 
}

and const_variant = {
  cv_name : string; 
  cv_constructors : (string * int) list;
}

and type_spec = 
  | Record of record 
  | Variant of variant
  | Const_variant of const_variant 

type type_ = {
  module_ : string; (* For now limit to a single module *)  
  spec : type_spec; 
  type_level_ppx_extension : string option; 
}
